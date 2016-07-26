From: Davide Caratti <dcaratti@redhat.com>
Subject: [iproute PATCH 0/3] improve MACsec support
Date: Tue, 26 Jul 2016 11:03:17 +0200
Message-ID: <cover.1469520298.git.dcaratti@redhat.com>
Cc: Phil Sutter <phil@nwl.cc>, Sabrina Dubroca <sd@queasysnail.net>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33819 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753214AbcGZJEV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2016 05:04:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

parsing of 'cipher' and 'icvlen' arguments has been improved; while at it,
a couple of missing printouts have been added to usage() functions in 
"ip addr help" and "ip link help". Finally, some errors in the man pages
have been fixed.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>

Davide Caratti (3):
  man: macsec: fix macsec related typos
  ip {link,address}: add 'macsec' item to TYPE list
  macsec: cipher and icvlen can be set separately

 ip/ipaddress.c           |  2 +-
 ip/iplink.c              |  2 +-
 ip/ipmacsec.c            | 52 ++++++++++++++++--------------------------------
 man/man8/ip-address.8.in |  3 ++-
 man/man8/ip-link.8.in    | 17 +++++++++++-----
 man/man8/ip-macsec.8     | 13 ++++++++----
 6 files changed, 42 insertions(+), 47 deletions(-)

-- 
2.5.5
