From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/5] soreuseport: infrastructure
Date: Sun, 20 Jan 2013 15:33:35 -0800
Message-ID: <CA+mtBx9n5KQuBxy7V7bNiXRs0NNUo7mk+O6txeJWeUsXmODKow@mail.gmail.com>
References: <alpine.DEB.2.00.1301141152130.3433@pokey.mtv.corp.google.com>
	<20130115075323.64b2fdc7@nehalam.linuxnetplumber.net>
	<1358266444.8744.5892.camel@edumazet-glaptop>
	<CA+mtBx9UqyM-wTmX_ojNdH=oQO28i_4aV_z5mz1OiKJBzRRNnw@mail.gmail.com>
	<1358363586.32167.17.camel@edumazet-glaptop>
	<20130116224734.GA28741@ppwaskie-mobl2.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, davem@davemloft.net,
	netdev@markandruth.co.uk
To: PJ Waskiewicz <WaskiewiczJr@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f175.google.com ([209.85.210.175]:34380 "EHLO
	mail-ia0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039Ab3ATXdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 18:33:36 -0500
Received: by mail-ia0-f175.google.com with SMTP id r4so2354625iaj.6
        for <netdev@vger.kernel.org>; Sun, 20 Jan 2013 15:33:36 -0800 (PST)
In-Reply-To: <20130116224734.GA28741@ppwaskie-mobl2.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> It would be pretty neat if the CPU layout could make it to this level, so
> that you could choose queues based on the shared cache layout.  e.g. if
> cores 0 and 2 shared the same L2 cache, then you can be intelligent about
> landing flows on those queues bound to those cores.  Essentially the info
> that feeds the cpuid utility being used to make even smarter decisions of
> flow tuning.
>
Indeed.  I think Ben's cpu_rmap code already pretty much does this...

> Cheers,
> -PJ
