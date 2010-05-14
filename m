From: Matt Mackall <mpm@selenic.com>
Subject: Re: loosing IPMI-card by loading netconsole
Date: Fri, 14 May 2010 17:16:53 -0500
Message-ID: <1273875413.15067.1348.camel@calx>
References: <20100514134544.GA26674@gretchen.aei.mpg.de>
	 <DDC57477F5D6F845A0DDCB99D3C4812D0CA63BB9E4@orsmsx510.amr.corp.intel.com>
	 <4BED79EB.1000204@kernel.org> <1273858653.15067.1335.camel@calx>
	 <4BEDCA89.7000707@kernel.org>
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
Received: from waste.org ([173.11.57.241]:47412 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968Ab0ENWQ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 18:16:56 -0400
In-Reply-To: <4BEDCA89.7000707@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-05-15 at 00:11 +0200, Tejun Heo wrote:
> Hello,
> 
> On 05/14/2010 07:37 PM, Matt Mackall wrote:
> >> On 2.6.27.39, netconsole + IPMI works fine.  On 2.6.32.7, as soon as
> >> netconsole is loaded, IPMI stops working.  Unloading netconsole
> >> doesn't revive IPMI but detaching the driver from the controller does.
> >> In both cases, usual networking works fine.
> > 
> > Looks like a job for bisect.
> 
> Yeap, sure, it would be effective but I kind of want to leave
> bisection as the last resort.  Bisection is a somewhat painful process
> especially when the machine isn't right next to you and someone who
> has overall knowledge can often identify the problem much easier with
> appropriate debugging info.

Well nothing jumps to mind in the netpoll/netconsole code and I haven't
heard any similar reports. My guess is it's something obscure, so I
think the sooner you start bisecting... Even one or two tests will get
us a lot closer to figuring out what changed in the last 1.5 years.

-- 
Mathematics is the supreme nostalgia of our time.


