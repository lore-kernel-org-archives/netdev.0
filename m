From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH v1 0/2] basic ioctl support for netlink sockets
Date: Thu, 17 Mar 2016 17:03:54 -0700
Message-ID: <1458259436-85275-1-git-send-email-ddecotig@gmail.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	David Decotigny <decot@googlers.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Edward Cree <ecree@solarflare.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Ken-ichirou MATSUZAWA <chamaken@gmail.com>,
	Florian Westphal <fw@strlen.de>,
	David Herrmann <dh.herrmann@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34403 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752066AbcCRAEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 20:04:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

This removes the requirement that ethtool be tied to the support
of a specific L3 protocol, also updates a comment.

############################################
# Patch Set Summary:

David Decotigny (2):
  ethtool: minor doc update
  netlink: add support for NIC driver ioctls

 include/uapi/linux/ethtool.h |  6 +++---
 net/netlink/af_netlink.c     | 10 +++++++++-
 2 files changed, 12 insertions(+), 4 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
