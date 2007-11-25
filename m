From: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Sun, 25 Nov 2007 13:21:44 -0800
Message-ID: <4749E768.9040002@linux-foundation.org>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au> <1195893216.4149.186.camel@johannes.berg> <20071124133200.GA27531@gondor.apana.org.au> <1195912176.4149.194.camel@johannes.berg> <20071124141319.GA27819@gondor.apana.org.au> <4748855C.5090103@linux-foundation.org> <20071125010814.GD31668@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071125010814.GD31668-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Sat, Nov 24, 2007 at 12:11:08PM -0800, Stephen Hemminger wrote:
>   
>> Then what about hardware that can't dma ethernet to non-aligned address.
>> Sky2 hardware breaks if DMA is not 8 byte aligned.  IMHO the IP stack should
>> handle any alignment, and do the appropriate memove if the CPU requires 
>> alignment.
>>     
>
> Luckily all sky2 users have been on x86 so far :)
>
> Here's an idea.  Put the data of the packet into the page frags
> where alignment is not an issue but copy the header so that it
> is aligned.
>
> Would that work?
>
> Cheers,
>   
No too wasteful. I'm working a patch to eth_type_trans to realign if 
needed for any device.
