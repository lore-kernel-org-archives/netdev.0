From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net 0/3] net/hsr: Fix omissions
Date: Fri, 29 Nov 2013 23:34:40 +0100
Message-ID: <52991680.1020707@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>,
	Javier Boticario <jboticario@gmail.com>,
	balferreira <balferreira@googlemail.com>,
	=?UTF-8?B?RWzDrWFzIE1vbGluYSBNdcOxb3o=?= <elias.molina@ehu.es>,
	Arvid Brodin <Arvid.Brodin@alten.se>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam2.webland.se ([91.207.112.92]:60801 "EHLO spam2.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751289Ab3K2Wp7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Nov 2013 17:45:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a patch series that fixes a few omissions in the original HSR p=
atch.

The HSR driver is completely new in v3.13-rc1, so the risk that someone=
 would
hit a regression should be very small. Also, the HSR driver is pretty u=
seless
without iproute support, which depends on patch 3 in the series. So I h=
ope=20
these are OK for net.

Arvid Brodin (3):
  MAINTAINERS: Added net/hsr/ maintainer
  net/hsr: Very small fix of comment style.
  net/hsr: Support iproute print_opt ('ip -details ...').

 MAINTAINERS                  |  6 ++++++
 include/uapi/linux/if_link.h |  4 +++-
 net/hsr/hsr_framereg.c       |  3 ++-
 net/hsr/hsr_netlink.c        | 28 ++++++++++++++++++++++++++++
 4 files changed, 39 insertions(+), 2 deletions(-)

--=20
1.8.1.5

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
