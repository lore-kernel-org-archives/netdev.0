From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Tue, 27 Nov 2007 09:16:07 -0800
Message-ID: <474C50D7.5010901@zytor.com>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au> <1195893216.4149.186.camel@johannes.berg> <20071124133200.GA27531@gondor.apana.org.au> <1195912176.4149.194.camel@johannes.berg> <20071124141319.GA27819@gondor.apana.org.au> <4748855C.5090103@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4748855C.5090103-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Herbert Xu wrote:
>> On Sat, Nov 24, 2007 at 02:49:36PM +0100, Johannes Berg wrote:
>>  
>>> Right. I just didn't think that would be a valid value for an
>>> architecture to set.
>>>     
>>
>> OK.  Let me clarify this a bit more.  We require at least one
>> of the following rules to be met:
>>
>> * the IPv4/IPv6 header is aligned by 8 bytes on reception;
>> * or the platform provides unaligned exception handlers.
>>
>> So if your platform violates both rules then it won't work with
>> the IP stack, simple as that.  Fortunately I don't think such a
>> platform exists currently on Linux.
>>
>> Cheers,
>>   
> 
> Then what about hardware that can't dma ethernet to non-aligned address.
> Sky2 hardware breaks if DMA is not 8 byte aligned.  IMHO the IP stack 
> should handle any alignment, and do the appropriate memove if the CPU requires 
> alignment.

I wrote a patch for the IP stack to realign packets if necessary at one 
point.  I should dredge it up again and submit it for collective flamage.

	-hpa
