From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: [net-next-2.6 PATCH 0/5] Phonet resource routing
Date: Thu, 16 Sep 2010 00:29:35 +0200
Message-ID: <d214bd6716258777ce8b1023208bc347@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:36499 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751809Ab0IOW3g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 18:29:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


   Hello,=0D
=0D
This patch series adds support for implement Phonet services ("servers"=
) on=0D
Linux. So far, this was only possible on the Phonet modem attached; i.e=
=2E=0D
Linux processes could only act as a "client".=0D
=0D
Comments welcome. (Or did I again miss the new feature deadline?)=0D
=0D
 Documentation/networking/phonet.txt |   16 +++=0D
 include/linux/phonet.h              |    2 =0D
 include/net/phonet/phonet.h         |    5 =0D
 include/net/phonet/pn_dev.h         |    1 =0D
 net/phonet/af_phonet.c              |   17 +++=0D
 net/phonet/datagram.c               |   13 ++=0D
 net/phonet/pn_dev.c                 |    2 =0D
 net/phonet/socket.c                 |  185=0D
++++++++++++++++++++++++++++++++++++=0D
 8 files changed, 241 insertions(+)=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

