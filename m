From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: WE-17 typo fix
Date: Tue, 28 Sep 2004 11:46:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928184625.GA8299@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

	Hi Jeff,

	Felix R. found a typo in the WE-17 patch I sent you and is
pending in your tree (more correctly, an overzealous
search&replace). The patch below fix this mistake.
	I would appreciate you adding this patch to your tree ;-)

	Have fun...

	Jean

------------------------------------------------------------------

diff -u -p linux/net/core/wireless.we17.c linux/net/core/wireless.c
--- linux/net/core/wireless.we17.c	Tue Sep 28 11:34:04 2004
+++ linux/net/core/wireless.c	Tue Sep 28 11:34:33 2004
@@ -867,7 +867,7 @@ static inline int ioctl_private_call(str
 				return -EFAULT;
 
 			/* Does it fits within bounds ? */
-			if(iwr->u.data.length > (descr->get_args &
+			if(iwr->u.data.length > (descr->set_args &
 						 IW_PRIV_SIZE_MASK))
 				return -E2BIG;
 		} else {
