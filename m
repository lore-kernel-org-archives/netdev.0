From: Antonio Almeida <vexwek@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 2 Jun 2009 12:45:28 +0100
Message-ID: <298f5c050906020445n3941b4ceic1167a4a028005bf@mail.gmail.com>
References: <20090517201528.GA8552@ami.dom.local>
	 <298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com>
	 <20090521085116.GC2892@ami.dom.local>
	 <298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com>
	 <20090523073201.GA2766@ami.dom.local>
	 <298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com>
	 <20090528211258.GA3658@ami.dom.local>
	 <298f5c050905291002j468aa6e6j9a28252507717660@mail.gmail.com>
	 <20090530200756.GF3166@ami.dom.local>
	 <298f5c050906020312r514c4638sfa2b504f55d71bc1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	kaber@trash.net, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.30]:51958 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760877AbZFBLp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 07:45:27 -0400
Received: by yw-out-2324.google.com with SMTP id 5so4641896ywb.1
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2009 04:45:28 -0700 (PDT)
In-Reply-To: <298f5c050906020312r514c4638sfa2b504f55d71bc1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 2, 2009 at 11:12 AM, Antonio Almeida wrote:
> I'm getting great values with this patch!
>...
> I'll get back to you with more values.

The steps are much smaller and the error keeps lower than 1%.
Injecting over 950Mpbs of tcp packets of 800bytes I get these values:

Configuration	Sent rate		error (%)
498000Kbit	495023Kbit	0,60
499000Kbit	497456Kbit	0,31
500000Kbit	497498Kbit	0,50
501000Kbit	497496Kbit	0,70
502000Kbit	499986Kbit	0,40
503000Kbit	499978Kbit	0,60
504000Kbit	502520Kbit	0,29
		
696000Kbit	690964Kbit	0,72
697000Kbit	695782Kbit	0,17
698000Kbit	695783Kbit	0,32
699000Kbit	695783Kbit	0,46
700000Kbit	695795Kbit	0,60
701000Kbit	695786Kbit	0,74
702000Kbit	700703Kbit	0,18
		
896000Kbit	888383Kbit	0,85
897000Kbit	896289Kbit	0,08
904000Kbit	896389Kbit	0,84
905000Kbit	904542Kbit	0,05

  Antonio Almeida
