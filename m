From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next 1/9] igb: Add support functions to access thermal
 data.
Date: Wed, 13 Jun 2012 18:06:29 +0100
Message-ID: <1339607189.2612.8.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1339230063-12545-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1339289333.21665.156.camel@deadeye.wl.decadent.org.uk>
	 <9BBC4E0CF881AA4299206E2E1412B626274A6F4B@ORSMSX102.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Wyborny, Carolyn" <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17916 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752834Ab2FMRGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 13:06:33 -0400
In-Reply-To: <9BBC4E0CF881AA4299206E2E1412B626274A6F4B@ORSMSX102.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-13 at 14:53 +0000, Wyborny, Carolyn wrote:
> >-----Original Message-----
> >From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> >Sent: Saturday, June 09, 2012 5:49 PM
> >To: Kirsher, Jeffrey T
> >Cc: davem@davemloft.net; Wyborny, Carolyn; netdev@vger.kernel.org;
> >gospo@redhat.com; sassmann@redhat.com
> >Subject: Re: [net-next 1/9] igb: Add support functions to access thermal
> >data.
> >
> >On Sat, 2012-06-09 at 01:20 -0700, Jeff Kirsher wrote:
> >> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> >>
> >> Some i350 devices contain thermal data that we can get to via an i2c
> >> interface.  These functions provide support to get at that data.  A
> >> following patch will export this data.
> >[...]
> >
> >We already have an I2C subsystem - so don't replicate i2c-algo-bit etc.
> >
> >It's possible we also have an hwmon driver for whatever temperature
> >sensor is on these boards, which you can then probe by calling
> >i2c_new_device().
> 
> I am not sure that our sensors will be compatible, but I will research
> it to be sure.  I will also take a look at what we can do with the i2c
> interface that already exists and make sure we are not duplicating any
> of it.

The patch you posted duplicates i2c-algo-bit.  The sfc driver initially
did this too, but I was rightly required to fix that.  So if you want an
example, you could do worse than looking for references to 'i2c' in
drivers/net/ethernet/sfc/falcon.c and
drivers/net/ethernet/sfc/falcon_boards.c.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
