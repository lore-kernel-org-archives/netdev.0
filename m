From: john stultz <johnstul@us.ibm.com>
Subject: Re: [PATCH NET-NEXT 01/10] clocksource: allow usage independent of
	timekeeping.c
Date: Wed, 04 Feb 2009 11:25:42 -0800
Message-ID: <1233775542.6994.13.camel@localhost.localdomain>
References: <1233752517-30010-1-git-send-email-patrick.ohly@intel.com>
	 <1233752517-30010-2-git-send-email-patrick.ohly@intel.com>
	 <1233756235.15119.54.camel@desktop> <1233758796.15940.198.camel@ecld0pohly>
	 <1233760170.15119.76.camel@desktop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick Ohly <patrick.ohly@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
To: Daniel Walker <dwalker@fifo99.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:60422 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752497AbZBDTZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 14:25:56 -0500
In-Reply-To: <1233760170.15119.76.camel@desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-02-04 at 07:09 -0800, Daniel Walker wrote:
> On Wed, 2009-02-04 at 15:46 +0100, Patrick Ohly wrote:
> > In an earlier revision of the patch I had adapted clocksource itself so
> > that it could be used outside of the time keeping code; John wanted me
> > to use these smaller structs instead that you now find in the current
> > patch.
> 
> Well, I think your original idea was better.. I don't think we need the
> duplication of underlying clocksource mechanics.
> 
> > Eventually John wants to refactor clocksource so that it uses them and
> > just adds additional elements in clocksource. Right now clocksource is a
> > mixture of different concepts. Breaking out cyclecounter and timecounter
> > is a first step towards that cleanup.
> 
> The problem I see is that your putting off the cleanup of struct
> clocksource with duplication.. It should go in reverse , you should use
> clocksources for your patch set. Which will motivate John to clean up
> the clocksource structure.

I strongly disagree. Misusing a established structure for unintended use
is just bad. What Patrick wants to use the counters for has very
different semantics then how clocksources are used.

I think having a bit of redundancy in two structures is good motivation
for me to clean up the clocksources to use cyclecounters.

thanks
-john

