From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Updated 8139too with NAPI
Date: Tue, 11 Nov 2003 19:20:18 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB17CC2.4090401@pobox.com>
References: <3F9070B6.9090306@pobox.com>	<873cdqbt6z.fsf@devron.myhome.or.jp>	<20031020131106.6862e951.shemminger@osdl.org>	<877k2ysohc.fsf@devron.myhome.or.jp>	<20031028114707.1d234da6.shemminger@osdl.org>	<3FA01629.2080202@pobox.com>	<873cdaabue.fsf@devron.myhome.or.jp>	<20031030104943.20b61af0.shemminger@osdl.org>	<87ekwu9tn4.fsf@devron.myhome.or.jp> <20031111143143.794909e8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031111143143.794909e8.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Here is the latest update for 8139too with NAPI.
> 
> The changes from last time were to get rid of some of the netif_poll_disable calls
> to avoid getting trapped by receive interrupt races.  It is okay for the interrupt
> code to enable the poll routine to run even if we are just about to suspend or
> change multicast list.


I'm OK with the patch, but like last time, it doesn't apply cleanly to 
net-drivers-2.5-exp...  About to post an update, can you please rediff 
against that?

	Jeff
