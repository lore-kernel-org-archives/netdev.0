From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Thu, 29 Nov 2007 16:28:34 -0800
Message-ID: <474F5932.1030103@zytor.com>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au> <1195893216.4149.186.camel@johannes.berg> <20071124133200.GA27531@gondor.apana.org.au> <1195912176.4149.194.camel@johannes.berg> <20071124141319.GA27819@gondor.apana.org.au> <4748855C.5090103@linux-foundation.org> <474C50D7.5010901@zytor.com> <20071129131107.GC8487@gondor.apana.org.au> <474EFBEB.5000804@zytor.com> <20071130002621.GI23769@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071130002621.GI23769-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Nov 29, 2007 at 09:50:35AM -0800, H. Peter Anvin wrote:
>> Uhm, most cards affected *ARE* Ethernet cards, due to the bloody 14-byte 
>> header.
> 
> Well most Ethernet drivers are using NET_IP_ALIGN which means that IP
> stack gets aligned packets only.
> 
> sky2 is the exception here, not the rule.
> 

It is, but it's not unique.  Several USB adapters have the same problem, 
for example.

	-hpa
