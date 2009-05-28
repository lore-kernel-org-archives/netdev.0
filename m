From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Thu, 28 May 2009 19:13:40 +0100
Message-ID: <298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com>
References: <20090517201528.GA8552@ami.dom.local>
	 <20090518065629.GA6006@ff.dom.local>
	 <298f5c050905180954m791c14eaxe1f4b2c92f952a2f@mail.gmail.com>
	 <298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com>
	 <20090521085116.GC2892@ami.dom.local>
	 <298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com>
	 <20090523073201.GA2766@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.240]:22274 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752910AbZE1SNk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 14:13:40 -0400
Received: by an-out-0708.google.com with SMTP id d40so11408790and.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2009 11:13:40 -0700 (PDT)
In-Reply-To: <20090523073201.GA2766@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 23, 2009 at 8:32 AM, Jarek Poplawski wrote:
> Actually, from these two I was more interested in iproute2 more
> fitting the kernel version. :-((It should be enough to have at least
> tc compiled properly, I guess.)
I installed iproute2-ss090115 with the new patch but the results are
the same for my test scenery. HTB keeps sending 620Mbit/s when I
configure it's ceil to 555Mbit/s, with 800 bytes packets long.

> Btw.: if at any point you think this testing is too disturbing to you
> etc., feel free to stop this or delay in time as you like.
I'm working on this, don't worry. Since I have a traffic
generator/analyser, any modification you would make I can test it.
You're free to ask.

I've been looking inside htb source code. The granularity problem
could be in the use qdisc_rate_table or near that.


  Antonio Almeida
