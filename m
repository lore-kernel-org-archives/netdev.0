From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Updated 8139too with NAPI
Date: Wed, 12 Nov 2003 11:01:31 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB2595B.8090506@pobox.com>
References: <3F9070B6.9090306@pobox.com> <873cdqbt6z.fsf@devron.myhome.or.jp>	<20031020131106.6862e951.shemminger@osdl.org>	<877k2ysohc.fsf@devron.myhome.or.jp>	<20031028114707.1d234da6.shemminger@osdl.org>	<3FA01629.2080202@pobox.com> <873cdaabue.fsf@devron.myhome.or.jp>	<20031030104943.20b61af0.shemminger@osdl.org>	<87ekwu9tn4.fsf@devron.myhome.or.jp>	<20031111143143.794909e8.shemminger@osdl.org> <87d6bx4ms1.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
In-Reply-To: <87d6bx4ms1.fsf@devron.myhome.or.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

OGAWA Hirofumi wrote:
>     netif_rx_complete(dev);
>     -- interrupted --
> 	in rtl8139_interrupt(),
> 		if (netif_rx_schedule_prep(dev)) {
> 			RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
> 			__netif_rx_schedule (dev);
> 		}
>     -- resume --
>     /* enable interrupt, but rx-poll is already scheduling */
>     RTL_W16_F(IntrMask, rtl8139_intr_mask);


good point...
