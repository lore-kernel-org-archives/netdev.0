From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Fw: [BUG/PATCH] CONFIG_NET_HW_FLOWCONTROL and SMP
Date: Thu, 02 Oct 2003 13:47:40 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F7C64BC.7030701@pobox.com>
References: <20030929123734.5bd97a47.akpm@osdl.org>	<16248.41796.797321.700866@robur.slu.se>	<3F78A691.1040406@pobox.com> <16252.17618.866515.952549@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, dfages@arkoon.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>, Andrew Morton <akpm@osdl.org>
In-Reply-To: <16252.17618.866515.952549@robur.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Robert Olsson wrote:
> 
> Jeff Garzik writes:
>  > 
>  > If someone had a NAPI patch for tulip, we could remove HW_FLOWCONTROL 
>  > option altogether :)
> 
> Hello!
> Here is something for 2.6.0-test6:
> 
> * ifdef's to keep current non-NAPI tulip intact
> 
> * Port based on Alexey's orig NAPI tulip design
>   (Only RX handled by dev->poll)
> 
> * tulip HW_FLOW removed
> 
> * NAPI and HW-mitigation options in Kconfig


Looks great to me.  I'll give it some testing here, and 99% likely will 
apply it.

Andrew, would you be willing to merge this into -mm for some 
simultaneous netwide testing?

FWIW, I seem to recall that the older NAPI patch you sent didn't apply 
for some reason.  But forget about that, this one looks good.

	Jeff
