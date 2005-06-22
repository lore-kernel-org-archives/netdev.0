From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [TG3]: About hw coalescing infrastructure.
Date: Wed, 22 Jun 2005 12:03:32 -0700
Message-ID: <1119467012.5325.15.camel@rh4>
References: <20050511.141530.57445142.davem@davemloft.net>
 <42B982D4.9040704@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eric Dumazet" <dada1@cosmosbay.com>
In-Reply-To: <42B982D4.9040704@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-06-22 at 17:25 +0200, Eric Dumazet wrote:

> Is there anything I can try to tune the coalescing ?
> Being able to handle 100 packets each interrupt instead of one or two would certainly help.
> I dont mind about latency. But of course I would like not to drop packets :)
> But maybe the BCM5702 is not able to delay an interrupt ?
> 

On the 5702 that supports CLRTCKS mode, you need to play around with the
following parameters in tg3.h. To reduce interrupts, you generally have
to increase the values.

#define  LOW_RXCOL_TICKS_CLRTCKS	 0x00000014
#define  LOW_TXCOL_TICKS_CLRTCKS	 0x00000048
#define  LOW_RXMAX_FRAMES		 0x00000005
#define  LOW_TXMAX_FRAMES		 0x00000035
#define  DEFAULT_RXCOAL_TICK_INT_CLRTCKS 0x00000014
#define  DEFAULT_TXCOAL_TICK_INT_CLRTCKS 0x00000014
#define  DEFAULT_RXCOAL_MAXF_INT	 0x00000005
#define  DEFAULT_TXCOAL_MAXF_INT	 0x00000005
