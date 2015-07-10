From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 02/11] soc/fsl: Introduce DPAA BMan device management
 driver
Date: Fri, 10 Jul 2015 16:12:12 -0500
Message-ID: <1436562732.2658.177.camel@freescale.com>
References: <1436473322-21247-1-git-send-email-Roy.Pledge@freescale.com>
	 <1436473322-21247-3-git-send-email-Roy.Pledge@freescale.com>
	 <1436528160.20619.159.camel@tiscali.nl>
	 <1436549595.2658.159.camel@freescale.com>
	 <BN3PR0301MB12673A340E327986F0BC39E58C9F0@BN3PR0301MB1267.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Paul Bolle <pebolle@tiscali.nl>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Pledge Roy-R01356 <roy.pledge@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BN3PR0301MB12673A340E327986F0BC39E58C9F0@BN3PR0301MB1267.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-07-10 at 15:57 -0500, Pledge Roy-R01356 wrote:
> > 
> > On Fri, 2015-07-10 at 13:36 +0200, Paul Bolle wrote:
> > > On do, 2015-07-09 at 16:21 -0400, Roy Pledge wrote:
> > > > +#ifdef CONFIG_FSL_DPA_CHECKING
> > > > +#define DPA_ASSERT(x) \
> > > > +   do { \
> > > > +           if (!(x)) { \
> > > > +                   pr_crit("ASSERT: (%s:%d) %s\n", __FILE__, 
> > > > __LINE__, \
> > > > +                           __stringify_1(x)); \
> > > > +                   dump_stack(); \
> > > > +                   panic("assertion failure"); \
> > > 
> > > Not my call, but why panic() here?
> > 
> > I'm pretty sure I've complained about this before (as well as all the
> > BUG_ONs).
> > 
> Is the concern here just the call to panic()?  I'm happy to change what 
> happens when an issue is detected but the DPA_ASSERT() calls are very 
> useful when testing changes to the driver and when bringing up the drivers 
> on new silicon variants. 

Use WARN_ON() or a variant thereof.

-Scott
