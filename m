From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v2 00/12] add support for new ETHTOOL_xLINKSETTINGS ioctls
Date: Thu,  3 Mar 2016 20:23:13 -0800
Message-ID: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35763 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149AbcCDEXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 23:23:36 -0500
Received: by mail-pf0-f196.google.com with SMTP id x188so338981pfb.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 20:23:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Decotigny <decot@googlers.com>

This adds support for the new ETHTOOL_xLINKSETTINGS ioctls. This also
fixes a few compilation warnings as well as a heap corruption bug.

History:
  v2
    added do_seeprom patch
    added netdev@ as recipient
  v1
    initial submission

############################################
# Patch Set Summary:

David Decotigny (8):
  ethtool.c: don't ignore fread() return value
  ethtool.c: fix dump_regs heap corruption
  ethtool.c: do_seeprom checks for params & stdin sanity
  ethtool-copy.h: sync with net-next
  internal.h: fix build for latest ethtool-copy.h
  internal.h: TRUE/FALSE macros
  ethtool.c: add support for ETHTOOL_xLINKSETTINGS ioctls
  ethtool.c: use v6 socket when v4 is not available

Maciej =C5=BBenczykowski (4):
  internal.h: change to new sane powerpc64 kernel headers
  marvell.c: fix strict alias warnings
  test-common.c: fix test_realloc(NULL, ...)
  test-features.c: add braces around array initialization

 ethtool-copy.h  | 485 ++++++++++++++++++++++++++++++------
 ethtool.c       | 752 ++++++++++++++++++++++++++++++++++++++++++------=
--------
 internal.h      |  85 ++++++-
 marvell.c       |  21 +-
 test-cmdline.c  |  12 +
 test-common.c   |   2 +-
 test-features.c |   2 +-
 7 files changed, 1085 insertions(+), 274 deletions(-)

--=20
2.7.0.rc3.207.g0ac5344
