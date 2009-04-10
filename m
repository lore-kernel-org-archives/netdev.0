From: Matt Mackall <mpm@selenic.com>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Thu, 09 Apr 2009 19:27:19 -0700
Message-ID: <1239330439.3342.2.camel@calx>
References: <200904061430.26276.rgetz@blackfin.uclinux.org>
	 <200904071744.17727.rgetz@blackfin.uclinux.org>
	 <1239220294.31467.55.camel@calx>
	 <200904090954.54601.rgetz@blackfin.uclinux.org>
	 <1239296459.31467.142.camel@calx>
	 <a24804730904091829k167668f1y6e546693b2f8e5da@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robin Getz <rgetz@blackfin.uclinux.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Chris Peterson <cpeterso@cpeterso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:58831 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756239AbZDJC2w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2009 22:28:52 -0400
In-Reply-To: <a24804730904091829k167668f1y6e546693b2f8e5da@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-09 at 18:29 -0700, Chris Peterson wrote:
> > Hmm, this is a purely internal interface. Not sure if we need to bother
> > with scheduling it. My plan was to simply get the new code in and sweep
> > the kernel.
> 
> Matt, sounds like you're volunteering? :)
> 
> >From my understanding, the roadmap looks something like:
> 
> 1. Add checkpatch warning about IRQF_SAMPLE_RANDOM
> 2. Add any new add_*_randomness() functions (e.g. RTC and main clocks?
> Serial or USB interrupts?)
> 3. Remove IRQF_SAMPLE_RANDOM macro (and checkpatch warning)
> 4. Add "pragmatic entropy accounting model"?

Yeah, I just sat down with Ted Tso this evening and hashed out a new
design. More to come.

-- 
http://selenic.com : development and support for Mercurial and Linux


