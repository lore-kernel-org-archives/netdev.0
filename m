From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 3/3] ptp: derive the device name from the
 parent device
Date: Fri, 21 Sep 2012 19:23:03 +0100
Message-ID: <1348251783.2521.42.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1348245523.git.richardcochran@gmail.com>
	 <9f2ed4a62d52182eeab86ad3dca7f6feeb68368a.1348245523.git.richardcochran@gmail.com>
	 <1348247965.2521.11.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120921173709.GB6129@netboy.at.omicron.at>
	 <02874ECE860811409154E81DA85FBB5818BFF5B4@ORSMSX105.amr.corp.intel.com>
	 <1348249258.2521.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <20120921181115.GE6129@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:38426 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753085Ab2IUSXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 14:23:07 -0400
In-Reply-To: <20120921181115.GE6129@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-21 at 20:11 +0200, Richard Cochran wrote:
> On Fri, Sep 21, 2012 at 06:40:58PM +0100, Ben Hutchings wrote:
> > On Fri, 2012-09-21 at 17:39 +0000, Keller, Jacob E wrote:
> > > With the device, it is possible to lookup the driver.
> > 
> > For PCI devices, yes.  But there is really no guarantee that device
> > names (as in dev_name()) are globally unique either.
> 
> Ben, I tried to implement your suggestion from September 7th.
> Don't you like it, or did I misunderstand you?

For programmatic purposes, setting the parent is the really useful
thing.

I think what I'm still missing from you is some explanation of what the
'clock name' is meant to be used as - a type name, a unique identifier,
a 'friendly name' for listing clocks in a user interface?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
