From: "David S. Miller" <davem@davemloft.net>
Subject: Re: TG3 fix for slow switches (Was: TG3 driver failure on HP
 16-way)
Date: Thu, 6 Jan 2005 15:19:10 -0800
Message-ID: <20050106151910.4d51673e.davem@davemloft.net>
References: <16839.27239.264551.415058@berry.gelato.unsw.EDU.AU>
	<20041220161552.2b88aa3d.davem@davemloft.net>
	<16839.30796.413939.333935@wombat.chubb.wattle.id.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: peterc@gelato.unsw.edu.au, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Peter Chubb <peterc@gelato.unsw.edu.au>
In-Reply-To: <16839.30796.413939.333935@wombat.chubb.wattle.id.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Peter, let me know if this patch solves your PHY link up problem
too.

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/06 14:53:55-08:00 davem@nuts.davemloft.net 
#   [TG3]: Return 0 when PHY read times out, not all-ones.
#   
#   Noticed by Peter Chubb.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# drivers/net/tg3.c
#   2005/01/06 14:53:07-08:00 davem@nuts.davemloft.net +1 -1
#   [TG3]: Return 0 when PHY read times out, not all-ones.
# 
diff -Nru a/drivers/net/tg3.c b/drivers/net/tg3.c
--- a/drivers/net/tg3.c	2005-01-06 14:54:21 -08:00
+++ b/drivers/net/tg3.c	2005-01-06 14:54:21 -08:00
@@ -485,7 +485,7 @@
 		udelay(80);
 	}
 
-	*val = 0xffffffff;
+	*val = 0x0;
 
 	frame_val  = ((PHY_ADDR << MI_COM_PHY_ADDR_SHIFT) &
 		      MI_COM_PHY_ADDR_MASK);
