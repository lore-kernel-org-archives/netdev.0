From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 1/4] Add correlated clocksource deriving system time
 from an auxiliary clocksource
Date: Sat, 5 Sep 2015 12:04:11 +0200
Message-ID: <20150905100411.GA15362@gmail.com>
References: <1440183128-1384-2-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1508222143530.3873@nanos>
 <B79D786B7111A34A8CF09F833429C493A90B2D1F@ORSMSX109.amr.corp.intel.com>
 <alpine.DEB.2.11.1509041438520.15006@nanos>
 <20150904151021.GF18489@twins.programming.kicks-ass.net>
 <20150904151743.GB16862@localhost.localdomain>
 <20150904154133.GI18489@twins.programming.kicks-ass.net>
 <alpine.DEB.2.11.1509041832440.15006@nanos>
 <B79D786B7111A34A8CF09F833429C493A90B2FDE@ORSMSX109.amr.corp.intel.com>
 <alpine.DEB.2.11.1509051044040.15006@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Hall, Christopher S" <christopher.s.hall@intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Richard Cochran <richardcochran@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:33184 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750756AbbIEKEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Sep 2015 06:04:16 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1509051044040.15006@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Thomas Gleixner <tglx@linutronix.de> wrote:

> On Fri, 4 Sep 2015, Hall, Christopher S wrote:
> > > Right, but we still do not know how that is going to be used. And
> > > that's the key question. As long as that is not answered all can do is
> > > wild guessing.
> > 
> > It's not wild guessing.  We do have it working on other OSs and have a pretty 
> > good idea of how it will work.  The DSP firmware will be largely identical for 
> > Linux.  I think now, we have a chicken and egg problem.
> 
> You have a totally different problem. You are just refusing to explain how all 
> that stuff is supposed to work and what kind of functionality you need exactly.

Yeah, so I'm just going to NAK this until things are improved:

   NAKed-by: Ingo Molnar <mingo@kernel.org>

it's not like we are overly bored in timekeeping and need the extra complexity as 
much as possible.

Proper, comprehensive, proactive technical description is needed, with proper 
changelogs, not just half-baked notes. If all that is fixed I'll lift my NAK.

Thanks,

	Ingo
