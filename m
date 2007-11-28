From: "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Tue, 27 Nov 2007 18:42:26 -0800
Message-ID: <474CD592.2020108@zytor.com>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au>	<1195893216.4149.186.camel@johannes.berg>	<20071124133200.GA27531@gondor.apana.org.au>	<1195912176.4149.194.camel@johannes.berg>	<20071124141319.GA27819@gondor.apana.org.au>	<4748855C.5090103@linux-foundation.org>	<474C50D7.5010901@zytor.com> <20071127103940.314c7844@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071127103940.314c7844-s08KbqtN0aBORcJjwVk881hTQxXnIo14@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> 
> Is there any standard kernel config define for "this platform can't do
> unaligned accesses"?
> 

Not that I know of, but there should be.

To be somewhat more complexicated, some platforms (e.g. MIPS) can do 
unaligned references quite cheaply, but they need different opcodes to 
do so.

	-hpa
