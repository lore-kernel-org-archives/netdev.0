From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 2 Jun 2009 13:08:58 +0000
Message-ID: <20090602130857.GA7690@ff.dom.local>
References: <298f5c050905221042t45017c5q8bc967d13c9b81cb@mail.gmail.com> <20090523073201.GA2766@ami.dom.local> <298f5c050905281113o10393c61ye3c0539d2b6efa20@mail.gmail.com> <20090528211258.GA3658@ami.dom.local> <298f5c050905291002j468aa6e6j9a28252507717660@mail.gmail.com> <20090530200756.GF3166@ami.dom.local> <298f5c050906020312r514c4638sfa2b504f55d71bc1@mail.gmail.com> <298f5c050906020445n3941b4ceic1167a4a028005bf@mail.gmail.com> <20090602123635.GC4239@ff.dom.local> <4A251EEE.4060903@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f216.google.com ([209.85.220.216]:37270 "EHLO
	mail-fx0-f216.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274AbZFBNJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 09:09:03 -0400
Received: by fxm12 with SMTP id 12so6491075fxm.37
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2009 06:09:04 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A251EEE.4060903@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 02, 2009 at 02:45:34PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Tue, Jun 02, 2009 at 12:45:28PM +0100, Antonio Almeida wrote:
>>> On Tue, Jun 2, 2009 at 11:12 AM, Antonio Almeida wrote:
>>>> I'm getting great values with this patch!
>>>> ...
>>>> I'll get back to you with more values.
>>> The steps are much smaller and the error keeps lower than 1%.
>>> Injecting over 950Mpbs of tcp packets of 800bytes I get these values:
>>
>> Nice values - should be acceptable, I guess. Alas this is not all, and
>> I'll ask you soon for re-testing HFSC (after another patch) or maybe
>> even some simple CBQ setup ;-)
>
> I didn't follow the full discussion, so I'm not sure which kind of
> arithmetic error you're attempting to cure. For the HFSC scaling
> factors, please just keep in mind that its also supposed to be
> very accurate at low bandwidths.

It's all here:

http://permalink.gmane.org/gmane.linux.network/129301

Of course, I'd appreciate any suggestions.

Thanks,
Jarek P.
