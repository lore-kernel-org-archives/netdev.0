From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH][1/4] b44: Ignore carrier lost errors
Date: Sun, 29 Aug 2004 16:49:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41324158.4020709@pobox.com>
References: <200408292218.00756.jolt@tuxbox.org> <200408292233.03879.jolt@tuxbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pekka Pietikainen <pp@ee.oulu.fi>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Florian Schirmer <jolt@tuxbox.org>
In-Reply-To: <200408292233.03879.jolt@tuxbox.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Your mailer is mangling the patches.  Can you please resend without this?

The patches need to be apply-able without MIME massaging.

	Jeff



=2D-- linux/drivers/net/b44.c-old1 2004-08-29 16:29:08.000000000 +0200
+++ linux/drivers/net/b44.c 2004-08-29 16:27:00.000000000 +0200
@@ -1347,7 +1347,10 @@ static struct net_device_stats *b44_get_
         hwstat->rx_symbol_errs);
=20
   nstat->tx_aborted_errors =3D hwstat->tx_underruns;
+#if 0
+ /* Carrier lost counter seems to be broken for some devices */
   nstat->tx_carrier_errors =3D hwstat->tx_carrier_lost;
+#endif
=20
   return nstat;
  }
