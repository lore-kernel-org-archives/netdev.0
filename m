From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v7 0/2] add support for new ETHTOOL_xLINKSETTINGS ioctls
Date: Thu,  9 Jun 2016 17:55:42 -0700
Message-ID: <1465520144-132788-1-git-send-email-ddecotig@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	Joe Perches <joe@perches.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35051 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbcFJAzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 20:55:51 -0400
Received: by mail-pa0-f65.google.com with SMTP id gp3so3821749pac.2
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 17:55:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

[ this is a plain re-post, same v7 as the ones previously sent ]

History:
  v7
    added ref to related kernel commit in netlink ioctl patch description
  v6
    re-added last patch, to use AF_NETLINK when AF_INET not available
  v5
    rebased main patch, removed last patch "use AF_LOCAL when AF_INET
    not available"
  v4
    review Ben Hutchings:
      using AF_UNIX instead of INET6 in the absence of v4 sockets
      use stdbool.h
      do_seeprom always fails when offset/length out of bounds
      sync to latest ethtool.h + kernel.h from net-next
      __SANE_USERSPACE_TYPES__ always defined
      cosmetic updates for var == const tests
      cosmetic updates for associativity in tests
  v3
    TRUE/FALSE obvious-ification
  v2
    added do_seeprom patch
    added netdev <at>  as recipient
  v1
    initial submission

############################################
# Patch Set Summary:

David Decotigny (2):
  ethtool.c: add support for ETHTOOL_xLINKSETTINGS ioctls
  ethtool: use netlink socket when AF_INET not available

 configure.ac   |   2 +-
 ethtool.c      | 688 ++++++++++++++++++++++++++++++++++++++++++++-------------
 internal.h     |  67 ++++++
 test-cmdline.c |  13 ++
 4 files changed, 611 insertions(+), 159 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
