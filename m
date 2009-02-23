From: =?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Subject: Re: NAPI of many interfaces with just an interruption source
Date: Mon, 23 Feb 2009 10:21:15 +0100
Message-ID: <b0438a630902230121l5f0d3af4id9f98b877869e192@mail.gmail.com>
References: <20090221131251.GA28821@gondor.apana.org.au>
	 <1235251162.8805.212.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:27901 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbZBWJVR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 04:21:17 -0500
Received: by fg-out-1718.google.com with SMTP id 16so2624323fgg.17
        for <netdev@vger.kernel.org>; Mon, 23 Feb 2009 01:21:15 -0800 (PST)
In-Reply-To: <1235251162.8805.212.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the help

On Sat, Feb 21, 2009 at 10:19 PM, Benjamin Herrenschmidt
<benh@kernel.crashing.org> wrote:
>
>> Ben has just done exactly the same thing for his driver so he
>> can tell you all about it and how to use his generic function :)
>
> Right, you can look how it's done in ibm_newemac. There's basically
> a "dummy" netdev which is created to handle the NAPI on behalf of
> the real ones. The new core function init_dummy_netdev() will set
> up that dummy netdev for you.
>
I am working with 2.26.7... I do not have that "init_dummy_netdev" for
what I see.

> If you look at how I do it in emac, the actual ports "register"
> internally with that "mal" module so that I can "poll" them when
> the main NAPI is polled.
>
I see how it works... Nice. So it seems there is API to work with NAPI
"out of" net interfaces. Perhaps that is what I need.

Just a question... Why do you register the dummy "mal" as a driver?
Should it not be enough to init it when the first real driver is
loaded?

Miguel =C1ngel
