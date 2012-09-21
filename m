From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [PATCH net-next 3/3] ptp: derive the device name from the
 parent device
Date: Fri, 21 Sep 2012 18:40:58 +0100
Message-ID: <1348249258.2521.25.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1348245523.git.richardcochran@gmail.com>
	 <9f2ed4a62d52182eeab86ad3dca7f6feeb68368a.1348245523.git.richardcochran@gmail.com>
	 <1348247965.2521.11.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120921173709.GB6129@netboy.at.omicron.at>
	 <02874ECE860811409154E81DA85FBB5818BFF5B4@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:15741 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932122Ab2IURlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:41:02 -0400
In-Reply-To: <02874ECE860811409154E81DA85FBB5818BFF5B4@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-21 at 17:39 +0000, Keller, Jacob E wrote:
> > -----Original Message-----
> > From: Richard Cochran [mailto:richardcochran@gmail.com]
> > Sent: Friday, September 21, 2012 10:37 AM
> > To: Ben Hutchings
> > Cc: netdev@vger.kernel.org; David Miller; Keller, Jacob E; Kirsher,
> > Jeffrey T; John Stultz; Vick, Matthew
> > Subject: Re: [PATCH net-next 3/3] ptp: derive the device name from the
> > parent device
> > 
> > On Fri, Sep 21, 2012 at 06:19:25PM +0100, Ben Hutchings wrote:
> > > On Fri, 2012-09-21 at 19:00 +0200, Richard Cochran wrote:
> > > > PTP Hardware Clock device have a name that appears under sysfs that
> > > > should identify the underlying device. Instead of leaving it up to
> > > > the driver to invent a name, this patch changes the registration to
> > > > automatically use the name from the parent device.
> > >
> > > I thought you wanted the driver name and not the parent device name?
> > 
> > Yes, I originally wanted the driver name, because it gives the user
> > information about the expected performance. But here I am bowing to
> > Jacob's suggestion that we really need to identify the device. Intel cards
> > with two ports have *two* clocks. Sad but true.
> > 
> 
> With the device, it is possible to lookup the driver.

For PCI devices, yes.  But there is really no guarantee that device
names (as in dev_name()) are globally unique either.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
