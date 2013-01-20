From: Tom St Denis <tstdenis@elliptictech.com>
Subject: Re: IPsec AH use of ahash
Date: Sun, 20 Jan 2013 12:33:38 -0500 (EST)
Message-ID: <1061016395.93207.1358703218325.JavaMail.root@elliptictech.com>
References: <50FC2366.1000509@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Mike Galbraith <bitbucket@online.de>,
	Eric Dumazet <erdnetdev@gmail.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	David Miller <davem@davemloft.net>,
	steffen klassert <steffen.klassert@secunet.com>,
	herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Michal Kubecek <mkubecek@suse.cz>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <50FC2366.1000509@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Original Message -----
> From: "H. Peter Anvin" <hpa@zytor.com>
> To: "Tom St Denis" <tstdenis@elliptictech.com>
> Cc: "Mike Galbraith" <bitbucket@online.de>, "Eric Dumazet" <erdnetdev@gmail.com>, "Waskiewicz Jr, Peter P"
> <peter.p.waskiewicz.jr@intel.com>, "David Miller" <davem@davemloft.net>, "steffen klassert"
> <steffen.klassert@secunet.com>, herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
> "Michal Kubecek" <mkubecek@suse.cz>
> Sent: Sunday, 20 January, 2013 12:03:34 PM
> Subject: Re: IPsec AH use of ahash
> 
> On 01/20/2013 07:07 AM, Tom St Denis wrote:
> >
> > In all likelihood I will submit a revised CMAC patch but it'll take
> > time before I can get business hours to work on it.  So instead of
> > having a maintainer just touch it up we're all going to lose out
> > because of pride?
> >
> 
> It's not about pride.  It is about the fact that maintainers don't
> scale.  A single troublesome contributor can easily take up as much
> maintainer time as over a dozen contributors who know how to work
> well
> with their upstream.

Ironically I'd view consistency with existing code as paramount over [say] adherence to some coding standard that none of the code I've seen in the kernel apparently sticks to in the first place.  In this case since XCBC and CMAC operate almost identically it made sense to me to copy it as a template.  Now you're telling me I have to re-write it... so that now it's different than XCBC?  Or are you suggesting that I also re-write XCBC?

Similarly AH4 and AH6 violate the coding standards.  Are you suggesting I re-write those entirely as well to merely augment its functionality?

For a project that *boasts* about it's abhorrent lack of commenting/documentation since "the source is the documentation" it's funny that you can't actually READ the source as an authority.

Tom
