From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.8.1-mm4 7/11] r8169: comment a gcc 2.95.x bug
Date: Tue, 24 Aug 2004 00:53:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040823225335.GG20726@electric-eye.fr.zoreil.com>
References: <20040823224100.GA14680@electric-eye.fr.zoreil.com> <20040823224425.GA20726@electric-eye.fr.zoreil.com> <20040823224548.GB20726@electric-eye.fr.zoreil.com> <20040823224706.GC20726@electric-eye.fr.zoreil.com> <20040823224813.GD20726@electric-eye.fr.zoreil.com> <20040823224927.GE20726@electric-eye.fr.zoreil.com> <20040823225120.GF20726@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040823225120.GF20726@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


gcc 2.95.3 bug has been experienced on gcc 2.95.4.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-070 drivers/net/r8169.c
--- linux-2.6.8.1/drivers/net/r8169.c~r8169-070	2004-08-23 23:30:03.000000000 +0200
+++ linux-2.6.8.1-fr/drivers/net/r8169.c	2004-08-23 23:30:03.000000000 +0200
@@ -1575,7 +1575,7 @@ rtl8169_start_xmit(struct sk_buff *skb, 
 		tp->Tx_skbuff[entry] = skb;
 		tp->TxDescArray[entry].addr = cpu_to_le64(mapping);
 
-		/* anti gcc 2.95.3 bugware */
+		/* anti gcc 2.95.[3/4] bugware - do not merge these lines */
 		status = DescOwn | FirstFrag | LastFrag | len |
 			 (RingEnd * !((entry + 1) % NUM_TX_DESC));
 		tp->TxDescArray[entry].opts1 = cpu_to_le32(status);

_
