From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH] net: davinci_emac: Add pre_open, post_stop platform
 callbacks
Date: Thu, 3 May 2012 21:22:22 +0100
Message-ID: <1336076542.2998.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120502234718.GA5432@animalcreek.com>
	 <B5906170F1614E41A8A28DE3B8D121433EA72820@DBDE01.ent.ti.com>
	 <20120503160917.GA11310@animalcreek.com>
	 <B5906170F1614E41A8A28DE3B8D121433EA73591@DBDE01.ent.ti.com>
	 <20120503184632.GA28089@animalcreek.com>
	 <B5906170F1614E41A8A28DE3B8D121433EA7366B@DBDE01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Mark A. Greer" <mgreer@animalcreek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
To: "Bedia, Vaibhav" <vaibhav.bedia@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30997 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758539Ab2ECUW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 16:22:29 -0400
In-Reply-To: <B5906170F1614E41A8A28DE3B8D121433EA7366B@DBDE01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-03 at 19:25 +0000, Bedia, Vaibhav wrote:
> On Fri, May 04, 2012 at 00:16:32, Mark A. Greer wrote:
> [...]
> > > 
> > > So, if I understood this correctly, it's effectively like blocking a low power
> > > state transition (here wfi execution) when EMAC is active?
> > 
> > Assuming "it" is my patch, correct.
> > 
> 
> Recently I was thinking about how to get certain drivers to disallow some or all
> low power states and to me this also seems to fall in a similar category.
> 
> One of the suggestions that I got was to check if the 'wakeup' entry associated with
> the device under sysfs could be leveraged for this. The PM code could maintain
> a whitelist (or blacklist) of devices and it decides the low power state to enter
> based on the 'wakeup' entries associated with these devices. In this particular case,
> maybe the driver could simply set this entry to non-wakeup capable when necessary and
> then let the PM code take care of skipping the wfi execution.
> 
> Thoughts/brickbats welcome :)

You can maybe (ab)use the pm_qos mechanism for this.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
