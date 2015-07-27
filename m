From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
Subject: RE: [PATCH 03/10] dpaa_eth: add configurable bpool thresholds
Date: Mon, 27 Jul 2015 12:54:09 +0000
Message-ID: <BL2PR03MB5454AAD79FE8530995B1B08E68E0@BL2PR03MB545.namprd03.prod.outlook.com>
References: <1437581806-17420-3-git-send-email-madalin.bucur@freescale.com>
	<1437587228.20787.26.camel@perches.com>
	<BL2PR03MB545AA0E6D98232FF43B6CE9E6810@BL2PR03MB545.namprd03.prod.outlook.com>
 <20150726.163520.846046458508685868.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "joe@perches.com" <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Scott Wood <scottwood@freescale.com>,
	Liberman Igal <Igal.Liberman@freescale.com>,
	"ppc@mindchasers.com" <ppc@mindchasers.com>,
	"pebolle@tiscali.nl" <pebolle@tiscali.nl>,
	"joakim.tjernlund@transmode.se" <joakim.tjernlund@transmode.se>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150726.163520.846046458508685868.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, July 27, 2015 2:35 AM
> To: Bucur Madalin-Cristian-B32716
> Cc: joe@perches.com; netdev@vger.kernel.org; linuxppc-
> dev@lists.ozlabs.org; linux-kernel@vger.kernel.org; Wood Scott-B07421;
> Liberman Igal-B31950; ppc@mindchasers.com; pebolle@tiscali.nl;
> joakim.tjernlund@transmode.se
> Subject: Re: [PATCH 03/10] dpaa_eth: add configurable bpool thresholds
> 
> From: Madalin-Cristian Bucur <madalin.bucur@freescale.com>
> Date: Fri, 24 Jul 2015 15:49:39 +0000
> 
> >> -----Original Message-----
> >> From: Joe Perches [mailto:joe@perches.com]
> >> On Wed, 2015-07-22 at 19:16 +0300, Madalin Bucur wrote:
> >> > Allow the user to tweak the refill threshold and the total number
> >> > of buffers in the buffer pool. The provided values are for one CPU.
> >>
> >> Any value in making these module parameters instead?
> >
> > I expect one would (hardly ever) change these to improve some corner
> > cases then use them with the new values. It may help in the tuning process
> > but afterwards the bloat to the bootcmd would probably be  a nuisance.
> 
> I think these should be controlled by the existing ethtool infrastructure.
> 
> Neither the Kconfig mechanism nor module parameters are appropriate, at
> all.

The existing ethtool options are for ring based drivers (ethtool -g / -G).
I would not use those as we are not using rings (they do not map well anyway).

We could introduce special options for our non-ring devices but for these
parameters in particular I'd just resort to defines in the code as it's
improbable one would want to change them.

Madalin
