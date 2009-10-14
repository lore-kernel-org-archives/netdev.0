From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH net-next 0/5] Phonet: basic routing support
Date: Wed, 14 Oct 2009 12:47:34 +0200
Message-ID: <06dcdf33b2a0132b2a05c3220735a81e@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36477 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932293AbZJNKsL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 06:48:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


   Hello,=0D
=0D
This patchset provides rudimentary support for routing Phonet packets.=0D
Configuration is done with the common rtnetlink infrastructure.=0D
=0D
This is useful when there is more than one Phonet interface in the same=
=0D
namespace,=0D
e.g. a serial bus to a cellular modem and a USB gadget function to a PC=
=2E=0D
=0D
Comments welcome.=0D
=0D
 include/net/phonet/phonet.h |    1=0D
 include/net/phonet/pn_dev.h |    6 ++=0D
 net/phonet/af_phonet.c      |   55 ++++++++++++++++--=0D
 net/phonet/pn_dev.c         |  131=0D
+++++++++++++++++++++++++++++++++++++++++---=0D
 net/phonet/pn_netlink.c     |  130=0D
+++++++++++++++++++++++++++++++++++++++++++=0D
 net/phonet/socket.c         |   21 +++++++=0D
 6 files changed, 333 insertions(+), 11 deletions(-)=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

