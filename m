From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: [PATCH] iphase fix.
Date: Thu, 15 May 2003 12:32:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030515113258.GA31078@suse.de>
References: <200305150417.h4F4HTRA025809@hera.kernel.org> <3EC3359D.5050207@pobox.com> <3EC336FE.1030805@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3EC336FE.1030805@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 15, 2003 at 02:43:10AM -0400, Jeff Garzik wrote:
 > Jeff Garzik wrote:
 > >>         dev_kfree_skb(skb);
 > >>-    else
 > >>-        netif_wake_queue(dev);
 > >>+    netif_wake_queue(dev);
 > >>     LEAVE("iph5526_send_packet");
 > >
 > >This appears to revert a fix.
 > >You only want to wake the queue if you have room to queue another skb.
 > 
 > Actually, I'm wrong.
 > 
 > But it could still use some looking-at.  You don't want to stop_queue at 
 > the beginning of send_packet and wake_queue at the end.  Instead, the 
 > queue should be awakened in the Tx completion routine, and the 
 > stop_queue should be moved from the beginning to the end of the function.

Bring it up with whoever merged it into 2.4..

		Dave
