From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.8-rc3-mm1 1/2] 8139too: Rx fifo/overflow recovery
Date: Wed, 11 Aug 2004 18:56:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <411AA42E.50804@pobox.com>
References: <20040805234336.A15407@electric-eye.fr.zoreil.com> <411A70CB.8060101@pobox.com> <20040811223243.GA8584@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Pasi Sjoholm <ptsjohol@cc.jyu.fi>,
        Hector Martin <hector@marcansoft.com>,
        OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040811223243.GA8584@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> [...]
> 
>>You _want_ to update those registers on every packet.  Otherwise the 
>>crappy 8139 chip breaks.
> 
> 
> The affected users noticed a clear difference when the update was in
> the no-packet branch instead of the packet processing loop. Btw the
> excerpt of the documentation outlined by Hirofumi san suggests that
> this update makes sense.
> 
> Any objection/suggestion regarding a patch which would allow the update
> in both branches ?

Both branches is fine.

You'll quickly hit the RX-error-requiring-reset condition if you don't 
update on each packet, though.

	Jeff
