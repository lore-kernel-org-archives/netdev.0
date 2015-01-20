From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH net-next v8 2/4] net: netcp: Add Keystone NetCP core
 ethernet driver
Date: Tue, 20 Jan 2015 18:26:37 +0100
Message-ID: <1421774797.29393.4.camel@x220>
References: <1421367172-19793-1-git-send-email-m-karicheri2@ti.com>
	  <1421367172-19793-2-git-send-email-m-karicheri2@ti.com>
	 <1421741935.9655.73.camel@x220> <54BE8BEA.3000100@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Wingman Kwok <w-kwok2@ti.com>,
	Valentin Rothberg <valentinrothberg@gmail.com>,
	davem@davemloft.net, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54BE8BEA.3000100@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-01-20 at 12:10 -0500, Murali Karicheri wrote:
> On 01/20/2015 03:18 AM, Paul Bolle wrote:
> > On Thu, 2015-01-15 at 19:12 -0500, Murali Karicheri wrote:
> >> diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
> >> index 605dd90..e11bcfa 100644
> >> --- a/drivers/net/ethernet/ti/Kconfig
> >> +++ b/drivers/net/ethernet/ti/Kconfig
> >> @@ -73,12 +73,23 @@ config TI_CPSW
> >>   config TI_CPTS
> >>   	boolean "TI Common Platform Time Sync (CPTS) Support"
> >>   	depends on TI_CPSW
> >> +	depends on TI_CPSW || TI_KEYSTONE_NET
> >
> > You probably meant to add
> >      || TI_KEYSTONE_NETCP
> >
> > here. Ie, add CP. But as this slipped through testing it _might_ not be
> > needed at all.
> 
> Currently CPTS driver is not used for NetCP. So I want to remove the 
> above Kconfig dependency from Kconfig and cpts.o from the Makefile. Do 
> you expect me to send an incremental patch for this to the netdev list? 

That's Dave's call. I think that Dave works with incremental patches
exclusively once things have hit (one of the trees that feed into)
linux-next.

> or can pick the attached patch that addresses this issue. Let me know.

I'm just the reporter. Please send it through the regular channels. That
would certainly include netdev.


Paul Bolle
