From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] 8139too NAPI for net-drivers-2.5-exp
Date: Wed, 19 Nov 2003 12:16:21 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBBA565.3090206@pobox.com>
References: <20031118161730.2690cb76.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, netdev@oss.sgi.com,
        Jes Sorensen <jes@wildopensource.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031118161730.2690cb76.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Here is the 8139too version in net-drivers-2.5-exp modified for NAPI.
> Also:
> 	64k receive ring - has to handle wrap for that case;
> 	   the NoWrap flag does nothing if using this big ring.
> 	assert() -> BUG_ON()
> 	
> To deal with the races with tx_timeout, put back in the rx_lock from earlier versions.


Applied with a "but"...  This patch still contains some errors WRT 8139 
hardware and the RX path.  But I'm comfortable with nailing those 
problems down during public testing of net-drivers-2.5-exp.

Hirofumi, Stephen, and others, please test, particularly packet floods 
with (a) tiny packets and (b) huge packets.  Ditto Jes, if you've still 
got hardware, and are interested in DoS fixes in 8139too.

	Jeff
