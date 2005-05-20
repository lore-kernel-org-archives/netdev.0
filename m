From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: A new driver for Broadcom bcm5706
Date: Fri, 20 May 2005 16:51:46 -0400
Message-ID: <428E4DE2.1020002@pobox.com>
References: <1116609329.31523.16.camel@rh4> <20050520194220.GA18259@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ffan@broadcom.com, lusinsky@broadcom.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Chan <mchan@broadcom.com>, davem@davemloft.net
In-Reply-To: <20050520194220.GA18259@havoc.gtf.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Note that I only consider a very few of these items, highlighted below, 
to be merge-stoppers.  The rest are minor things that can be fixed up at 
leisure.

> 8) excessive stack size in bnx2_alloc_bad_rbuf():

> 9) [additional review]  DaveM, others: is this correct for all arches?

> 13) [additional review] why is CHECKSUM_UNNECESSARY used when
> cksum==0xffff or cksum==0 ?

> 15) the following loop is just silly.  use mdelay or (preferably)
> msleep.

> 19) [additional review] need flush_scheduled_work(), if using work queues?

> 21) need to call bnx2_netif_stop() in bnx2_close()

> 27) isn't 'timer_interval == HZ' too rapid a timer?  Does it really need
> to fire every second?
