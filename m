From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] (4/8) dscc4 convert to new hdlc_device
Date: Tue, 2 Dec 2003 23:48:11 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202234811.A10194@electric-eye.fr.zoreil.com>
References: <20031202135846.28a93010.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Halas <khc@pm.waw.pl>, Jeff Garzik <jgarzik@pobox.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031202135846.28a93010.shemminger@osdl.org>; from shemminger@osdl.org on Tue, Dec 02, 2003 at 01:58:46PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]

drivers/net/wan/dscc4.c:1502:
                i = dev_per_card - 1;
                do {
                        dscc4_rx_irq(priv, root + i);
                                           ^^^^^^^^ -> __BOOOOM__
                } while (--i >= 0);

Anyway it is a long expected change, I'll fix/test it.

--
Ueimor
