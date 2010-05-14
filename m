From: Tejun Heo <tj@kernel.org>
Subject: Re: loosing IPMI-card by loading netconsole
Date: Sat, 15 May 2010 00:24:07 +0200
Message-ID: <4BEDCD87.4090602@kernel.org>
References: <20100514134544.GA26674@gretchen.aei.mpg.de>	 <DDC57477F5D6F845A0DDCB99D3C4812D0CA63BB9E4@orsmsx510.amr.corp.intel.com>	 <4BED79EB.1000204@kernel.org> <1273858653.15067.1335.camel@calx>	 <4BEDCA89.7000707@kernel.org> <1273875413.15067.1348.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	Henning Fehrmann <henning.fehrmann@aei.mpg.de>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:39213 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752531Ab0ENWYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 18:24:16 -0400
In-Reply-To: <1273875413.15067.1348.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 05/15/2010 12:16 AM, Matt Mackall wrote:
>> Yeap, sure, it would be effective but I kind of want to leave
>> bisection as the last resort.  Bisection is a somewhat painful process
>> especially when the machine isn't right next to you and someone who
>> has overall knowledge can often identify the problem much easier with
>> appropriate debugging info.
> 
> Well nothing jumps to mind in the netpoll/netconsole code and I haven't
> heard any similar reports. My guess is it's something obscure, so I
> think the sooner you start bisecting... Even one or two tests will get
> us a lot closer to figuring out what changed in the last 1.5 years.

I see.  I was hoping it would ring a bell to someone.  We'll probably
try to provide the info Jesse asked and if that doesn't lead anywhere
start bisecting.

Thank you.

-- 
tejun
