From: Chris Peterson <cpeterso@cpeterso.com>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Thu, 9 Apr 2009 18:29:10 -0700
Message-ID: <a24804730904091829k167668f1y6e546693b2f8e5da@mail.gmail.com>
References: <200904061430.26276.rgetz@blackfin.uclinux.org>
	 <200904071744.17727.rgetz@blackfin.uclinux.org>
	 <1239220294.31467.55.camel@calx>
	 <200904090954.54601.rgetz@blackfin.uclinux.org>
	 <1239296459.31467.142.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Robin Getz <rgetz@blackfin.uclinux.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:17122 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754815AbZDJB3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2009 21:29:12 -0400
In-Reply-To: <1239296459.31467.142.camel@calx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hmm, this is a purely internal interface. Not sure if we need to bother
> with scheduling it. My plan was to simply get the new code in and sweep
> the kernel.

Matt, sounds like you're volunteering? :)

>From my understanding, the roadmap looks something like:

1. Add checkpatch warning about IRQF_SAMPLE_RANDOM
2. Add any new add_*_randomness() functions (e.g. RTC and main clocks?
Serial or USB interrupts?)
3. Remove IRQF_SAMPLE_RANDOM macro (and checkpatch warning)
4. Add "pragmatic entropy accounting model"?


chris
