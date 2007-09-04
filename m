From: "Mandeep Baines" <mandeep.baines@gmail.com>
Subject: Re: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating condition
Date: Tue, 4 Sep 2007 10:24:17 -0700
Message-ID: <535ddc6b0709041024r1c386426ye6ee99ce78295069@mail.gmail.com>
References: <20070904032036.GA11153@ludhiana>
	 <1188925008-ced672f60b90353067426d0b9f74506a@brownhat.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, davem@davemloft.net, rick.jones2@hp.com,
	msb@google.com, netdev@vger.kernel.org, grundler@google.com,
	robert.olsson@its.uu.se, jeff@garzik.org, nhorman@tuxdriver.com
To: "Daniele Venzano" <venza@brownhat.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:31495 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754891AbXIDRYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 13:24:19 -0400
Received: by fk-out-0910.google.com with SMTP id z23so1704005fkz
        for <netdev@vger.kernel.org>; Tue, 04 Sep 2007 10:24:17 -0700 (PDT)
In-Reply-To: <1188925008-ced672f60b90353067426d0b9f74506a@brownhat.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cool. I'll try to see if I can clock my pc lower and run the
experiments again. I'll measure cpu utilization also this time around.
That should be useful for extrapolating.

Regards,
Mandeep

On 9/4/07, Daniele Venzano <venza@brownhat.org> wrote:
> ----- Message d'origine -----
> De: Mandeep Singh Baines <mandeep.baines@gmail.com>
> Date: Mon, 3 Sep 2007 20:20:36 -0700
> Sujet: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating condition
>
> >Hi Daniele,
> >
> >Attached is a patch for converting the sis900 driver to NAPI. Please take a
> >look at let me know what you think. I'm not 100% sure if I'm handling the
> >rotting packet issue correctly or that I have the locking right in tx_timeout.
> >These might be areas to look at closely.
> >
> >I didn't see much saving in interrupts on my machine (too fast, I guess). But
> >I still think its beneficial: pushing work out of the interrupt handler into
> >a bottom half is a good thing and we no longer need to disable interrupts
> >in start_xmit.
> >
> >I did see a significant boost to tx performance by optimizing start_xmit: more
> >than double pps in pktgen.
> >
> >I'm also attaching some test results for various iterations of development.
>
> The patch looks good and I think it can be pushed higher (-mm ?) for some wider
> testing. I don't have the hardware available to do some tests myself,
> unfortunately, but it would be similar to yours anyway.
>
> I'd like to know how this works for people with less memory and slower CPU, but any
> kind of test run will be appreciated.
>
> Thanks, bye.
>
>
> --
> Daniele Venzano
> venza@brownhat.org
>
