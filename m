From: Daniele Venzano <venza@brownhat.org>
Subject: Re: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating
	 condition
Date: Tue, 04 Sep 2007 18:56:48 +0200
Message-ID: <1188925008-ced672f60b90353067426d0b9f74506a@brownhat.org>
References: <20070904032036.GA11153@ludhiana>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Mandeep Baines <mandeep.baines@gmail.com>,
	davem@davemloft.net, rick.jones2@hp.com, msb@google.com,
	netdev@vger.kernel.org, grundler@google.com,
	robert.olsson@its.uu.se, jeff@garzik.org, nhorman@tuxdriver.com
To: Mandeep Singh Baines <mandeep.baines@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.infomaniak.ch ([84.16.68.89]:49218 "EHLO
	smtp1.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752316AbXIDQ5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 12:57:52 -0400
In-Reply-To: <20070904032036.GA11153@ludhiana>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Message d'origine -----
De: Mandeep Singh Baines <mandeep.baines@gmail.com>
Date: Mon, 3 Sep 2007 20:20:36 -0700
Sujet: [PATCH] [sis900] convert to NAPI, WAS Re: pktgen terminating condition

>Hi Daniele,
>
>Attached is a patch for converting the sis900 driver to NAPI. Please take a
>look at let me know what you think. I'm not 100% sure if I'm handling the
>rotting packet issue correctly or that I have the locking right in tx_timeout.
>These might be areas to look at closely.
>
>I didn't see much saving in interrupts on my machine (too fast, I guess). But
>I still think its beneficial: pushing work out of the interrupt handler into
>a bottom half is a good thing and we no longer need to disable interrupts 
>in start_xmit. 
>
>I did see a significant boost to tx performance by optimizing start_xmit: more
>than double pps in pktgen.
>
>I'm also attaching some test results for various iterations of development.

The patch looks good and I think it can be pushed higher (-mm ?) for some wider 
testing. I don't have the hardware available to do some tests myself, 
unfortunately, but it would be similar to yours anyway.

I'd like to know how this works for people with less memory and slower CPU, but any 
kind of test run will be appreciated.

Thanks, bye.


--
Daniele Venzano
venza@brownhat.org
