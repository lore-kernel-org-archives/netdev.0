From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH net-next 3/3] ptp: derive the device name from the
 parent device
Date: Fri, 21 Sep 2012 17:39:02 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5818BFF5B4@ORSMSX105.amr.corp.intel.com>
References: <cover.1348245523.git.richardcochran@gmail.com>
 <9f2ed4a62d52182eeab86ad3dca7f6feeb68368a.1348245523.git.richardcochran@gmail.com>
 <1348247965.2521.11.camel@bwh-desktop.uk.solarflarecom.com>
 <20120921173709.GB6129@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: Richard Cochran <richardcochran@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:6921 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932070Ab2IURjG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:39:06 -0400
In-Reply-To: <20120921173709.GB6129@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Friday, September 21, 2012 10:37 AM
> To: Ben Hutchings
> Cc: netdev@vger.kernel.org; David Miller; Keller, Jacob E; Kirsher,
> Jeffrey T; John Stultz; Vick, Matthew
> Subject: Re: [PATCH net-next 3/3] ptp: derive the device name from the
> parent device
> 
> On Fri, Sep 21, 2012 at 06:19:25PM +0100, Ben Hutchings wrote:
> > On Fri, 2012-09-21 at 19:00 +0200, Richard Cochran wrote:
> > > PTP Hardware Clock device have a name that appears under sysfs that
> > > should identify the underlying device. Instead of leaving it up to
> > > the driver to invent a name, this patch changes the registration to
> > > automatically use the name from the parent device.
> >
> > I thought you wanted the driver name and not the parent device name?
> 
> Yes, I originally wanted the driver name, because it gives the user
> information about the expected performance. But here I am bowing to
> Jacob's suggestion that we really need to identify the device. Intel cards
> with two ports have *two* clocks. Sad but true.
> 

With the device, it is possible to lookup the driver.

- Jake

> Thanks,
> Richard
