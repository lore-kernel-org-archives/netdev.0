From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Network device autoconfiguration
Date: Mon, 31 Aug 2009 15:19:54 +0200
Message-ID: <bd8484914903fecf95d193d4ac9f9295@chewa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:46474 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753280AbZHaNTw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2009 09:19:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


   Hello,=0D
=0D
The kernel will automatically configure the loopback device, especially=
,=0D
add 127.0.0.1 and ::1 address. This is detected with the IFF_LOOPBACK f=
lag.=0D
In *some* cases, it would be statically determine the Phonet address of=
 a=0D
device, but I wonder how to pass the information from the net_device dr=
iver=0D
to the stack... Would a device ioctl() be appropriate? Or is the whole=0D
thing just a bad idea? Or something else?=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

