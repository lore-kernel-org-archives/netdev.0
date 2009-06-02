From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 02 Jun 2009 14:45:34 +0200
Message-ID: <4A251EEE.4060903@trash.net>
References: <298f5c050905181016w552b283q2bb2ec508433525a@mail.gmail.com> <20090521085116.GC2892@ami.dom.local> <298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com> <20090523073201.GA2766@ami.dom.local> <298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com> <20090528211258.GA3658@ami.dom.local> <298f5c050905291002j468aa6e6j9a28252507717660@mail.gmail.com> <20090530200756.GF3166@ami.dom.local> <298f5c050906020312r514c4638sfa2b504f55d71bc1@mail.gmail.com> <298f5c050906020445n3941b4ceic1167a4a028005bf@mail.gmail.com> <20090602123635.GC4239@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38631 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbZFBMpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 08:45:36 -0400
In-Reply-To: <20090602123635.GC4239@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Jun 02, 2009 at 12:45:28PM +0100, Antonio Almeida wrote:
>> On Tue, Jun 2, 2009 at 11:12 AM, Antonio Almeida wrote:
>>> I'm getting great values with this patch!
>>> ...
>>> I'll get back to you with more values.
>> The steps are much smaller and the error keeps lower than 1%.
>> Injecting over 950Mpbs of tcp packets of 800bytes I get these values:
> 
> Nice values - should be acceptable, I guess. Alas this is not all, and
> I'll ask you soon for re-testing HFSC (after another patch) or maybe
> even some simple CBQ setup ;-)

I didn't follow the full discussion, so I'm not sure which kind of
arithmetic error you're attempting to cure. For the HFSC scaling
factors, please just keep in mind that its also supposed to be
very accurate at low bandwidths.

