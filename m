From: Julius Volz <juliusv@google.com>
Subject: [PATCHv3 0/2] IPVS: Add Generic Netlink configuration interface
Date: Thu,  7 Aug 2008 16:43:37 +0200
Message-ID: <1218120219-1117-1-git-send-email-juliusv@google.com>
Cc: horms@verge.net.au, kaber@trash.net, davem@davemloft.net,
	tgraf@suug.ch, vbusam@google.com
To: julius.volz@gmail.com, netdev@vger.kernel.org,
	lvs-devel@vger.kernel.org
Return-path: <lvs-devel-owner@vger.kernel.org>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the third iteration of the IPVS Netlink interface, this time
with only a small fix for a typo found by Thomas Graf. If there are no
further major issues, can this be applied?

The two patches add a Generic Netlink interface to IPVS while keeping
the old get/setsockopt interface for userspace backwards compatibility.
The motivation for this is to have a more extensible interface for
future changes, such as the planned IPv6 support.

An ipvsadm that already uses the new interface is available here:

http://sixpak.org/vince/google/ipvsadm/
(by Vince Busam)

Old ipvsadms continue to work with this change.
