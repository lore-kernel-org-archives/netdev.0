From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.12-rcx networking oops
Date: Tue, 31 May 2005 16:12:20 -0700
Message-ID: <20050531161220.4af50a69.akpm@osdl.org>
References: <20050531224012.GA16789@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, herbert@gondor.apana.org.au
Return-path: <netdev-bounce@oss.sgi.com>
To: Phil Oester <kernel@linuxace.com>
In-Reply-To: <20050531224012.GA16789@linuxace.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Phil Oester <kernel@linuxace.com> wrote:
>
> At Andrew's suggestion, I tested the latest 2.6.12-rc5-gitx, and am still
>  hitting an oops on a gateway box under load.  From comparing the various
>  oops, it seems like a dev is disappearing while one CPU is in the middle
>  of processing traffic.  At least that's what my naive analysis leads
>  me to believe.

Are you _sure_ the hardware is good?

Are you running anything which would cause netdevs to be destroyed? 
Bringing virtual devices up and down?  TUN/TAP driver?  Bonding driver? 
Anything like that?

Have you tried CONFIG_DEBUG_SLAB and/or CONFIG_DEBUG_PAGEALLOC?
