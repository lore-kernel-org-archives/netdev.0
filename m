From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH -next] net: hisilicon: Never build on SPARC
Date: Fri, 06 Nov 2015 21:30:17 +0100
Message-ID: <3819536.piFndcizrV@wuerfel>
References: <1445437773-23261-1-git-send-email-linux@roeck-us.net> <20151021215320.GB23371@roeck-us.net> <20151106191652.GA4046@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151106191652.GA4046@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 06 November 2015 11:16:52 Guenter Roeck wrote:
> On Wed, Oct 21, 2015 at 02:53:20PM -0700, Guenter Roeck wrote:
> > On Wed, Oct 21, 2015 at 09:11:53PM +0200, Arnd Bergmann wrote:
> > > On Wednesday 21 October 2015 10:03:05 Guenter Roeck wrote:
> > > > Anyway, if it gets that complicated, I think we should stick with
> > > > just returning OF_BAD_ADDR. The above really suggests the need for
> > > > an architecture specific solution.
> > > 
> > > Probably no harm in this really: the far more common
> > > of_address_to_resource() and of_iomap() helpers are equally
> > > broken on SPARC and we just return a runtime error for those
> > > as well without CONFIG_OF_ADDRESS rather than breaking the build.
> > > 
> > Agreed. Given this, returning OF_BAD_ADDR sounds like a better choice.
> > 
> Arnd,
> 
> do you know if a fix for this problem is pending in some branch ?
> Mainline sparc builds are now affected.
> 

I don't think anyone wrote the patch to do this. Can you send one?

	Arnd
