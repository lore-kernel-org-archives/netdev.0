From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: PROBLEM: fix fealnx.c hangs on SMP, 2.4.27
Date: Mon, 30 Aug 2004 13:33:00 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <413364CC.8090901@pobox.com>
References: <38386.192.168.1.2.1093850895.squirrel@www.it-technology.at> <200408301157.03334.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Peter Holik <peter@holik.at>, linux-kernel@vger.kernel.org,
        Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200408301157.03334.vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Denis Vlasenko wrote:
> On Monday 30 August 2004 10:28, Peter Holik wrote:
> 
>>static void set_rx_mode(struct net_device *dev)
>>{
>>   spinlock_t *lp = &((struct netdev_private *)dev->priv)->lock;
>>   unsigned long flags;
>>   spin_lock_irqsave(lp, flags);
>>   __set_rx_mode(dev);
>>-  spin_unlock_irqrestore(&lp, flags);
>>+  spin_unlock_irqrestore(lp, flags);
>>}
> 
> 
> Oh... it was my change which was buggy... Thanks for the fix!
> 
> Jeff, 2.6 most probably has the same bug.


Upstream 2.6 already has the fix...

	Jeff
