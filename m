From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.8-rc3-mm1 1/2] 8139too: Rx fifo/overflow recovery
Date: Wed, 11 Aug 2004 15:17:31 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411A70CB.8060101@pobox.com>
References: <20040805234336.A15407@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Pasi Sjoholm <ptsjohol@cc.jyu.fi>,
        Hector Martin <hector@marcansoft.com>,
        OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040805234336.A15407@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> This patch allows to update the interrupt status register after an 
> Rx overflow or a Rx fifo error even when the Rx buffer contains no packet.
> As a side effect it saves a few heavy (i.e. flushed) pci ops per received
> packet when several packets are received at the same time.


You _want_ to update those registers on every packet.  Otherwise the 
crappy 8139 chip breaks.

	Jeff
