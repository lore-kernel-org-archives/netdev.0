From: prashant s <sree_prash@yahoo.com>
Subject: Regarding NAPI performance
Date: Mon, 26 Apr 2004 11:40:39 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040426184039.91977.qmail@web60210.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

sir,
    i have a doubt on NAPI(feature which was
introduced in linux 2.6.3).In which polling is used
instead of interrupts when packets arrive at the
network card.

	i did not find any performance difference between a
non NAPI driver and a NAPI driver(this may be because
i used large packets).Both  of them showed 94Mbps,but
when i reduced the "DMA receive ring size" from 32k to
8k, i got a  performance difference. The ordinary
driver without NAPI (rtl8139too in 2.4.20 linux)
showed 72Mbps and the NAPI driver (rtl8139too in
2.6.3) showed 94Mbps,both having their ring size at
8k.The packet size i used was same as before.

    why is this difference when the ring size is
reduced.



   waiting for your reply.



  prashant   =20



=09
	=09
__________________________________
Do you Yahoo!?
Yahoo! Photos: High-quality 4x6 digital prints for 25=A2
http://photos.yahoo.com/ph/print_splash
