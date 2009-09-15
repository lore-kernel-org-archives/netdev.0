From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 0/5] Phonet: basic routing support
Date: Tue, 15 Sep 2009 13:30:19 +0200
Message-ID: <a9972d3fe3d2bf09387bee7827b571c0@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:59198 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752031AbZIOLaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Sep 2009 07:30:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


   Hello,=0D
=0D
This small patch series adds simplistic routing support to the Phonet=0D
stack. Usually, there is an "upstream" interface to the Phonet modem.=0D
However, if Linux runs on an embedded USB gadget, we have two interface=
s in=0D
the same namespace:=0D
- an internal interface to the modem (e.g. OMAP SSI bus), and=0D
- an external interface to the USB host (CDC Phonet).=0D
=0D
Patches follow.=0D
 include/linux/phonet.h      |    1=0D
 include/net/phonet/pn_dev.h |    6 ++=0D
 net/phonet/af_phonet.c      |   55 ++++++++++++++++--=0D
 net/phonet/pn_dev.c         |  131=0D
+++++++++++++++++++++++++++++++++++++++++---=0D
 net/phonet/pn_netlink.c     |  130=0D
+++++++++++++++++++++++++++++++++++++++++++=0D
 5 files changed, 312 insertions(+), 11 deletions(-)=0D
=0D
I am not sure if feature patches are still allowed. If not, I can just=0D
repost this at a more convenient time.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

