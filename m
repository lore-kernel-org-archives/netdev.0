From: Matt Mackall <mpm@selenic.com>
Subject: Re: loosing IPMI-card by loading netconsole
Date: Fri, 14 May 2010 12:37:33 -0500
Message-ID: <1273858653.15067.1335.camel@calx>
References: <20100514134544.GA26674@gretchen.aei.mpg.de>
	 <DDC57477F5D6F845A0DDCB99D3C4812D0CA63BB9E4@orsmsx510.amr.corp.intel.com>
	 <4BED79EB.1000204@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([173.11.57.241]:44251 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756760Ab0ENRhh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 13:37:37 -0400
In-Reply-To: <4BED79EB.1000204@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-05-14 at 18:27 +0200, Tejun Heo wrote:
> Hello, John.
> 
> As Henning seems offline, I'll try to fill in.
> 
> On 05/14/2010 04:51 PM, Ronciak, John wrote:
> > Sorry to hear about the problem you are having Henning.  What do you
> > mean when you say "it disappears"?
> 
> It stops responding to IPMI requests.
> 
> > Can both eth0 and eth1 ping (or be pinged)?  Do all the networking
> > devices still show up in the system when you do an 'lspci'?
> 
> Yeah, everything other than IPMI works just fine.
> 
> > What happens if you down and then up the interface you are having
> > problems with?  Does 'rmmod' do the same thing as your removal
> > method?
> 
> Haven't tried these but well I think rmmoding should achieve about the
> same thing.
> 
> > Is there anything in the system logs saying anything about the
> > interfaces?
> 
> Nope.
> 
> > We have not had reports of this so this is a bit unusual.  Please let us know.
> > 
> > Does this happen on other systems as well or just one particular system?
> 
> Yeah, it happens on at least several hundred machines, so not an
> isolated hardware issue at all.
> 
> To sum up.
> 
> On 2.6.27.39, netconsole + IPMI works fine.  On 2.6.32.7, as soon as
> netconsole is loaded, IPMI stops working.  Unloading netconsole
> doesn't revive IPMI but detaching the driver from the controller does.
> In both cases, usual networking works fine.

Looks like a job for bisect.

-- 
Mathematics is the supreme nostalgia of our time.


