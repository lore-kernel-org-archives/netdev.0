From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Wed, 3 Jun 2009 10:27:47 +0000
Message-ID: <20090603102747.GD5644@ff.dom.local>
References: <4A252714.2020008@trash.net> <20090602213723.GB2850@ami.dom.local> <4A259EB2.5010500@gmail.com> <4A2620FD.8030708@trash.net> <20090603074049.GA5254@ff.dom.local> <4A262BE7.4090807@trash.net> <20090603095412.GC5644@ff.dom.local> <4A264A13.3030005@trash.net> <4A264AE8.2050105@trash.net> <4A264B12.5030303@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:39318 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbZFCK1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 06:27:52 -0400
Received: by fg-out-1718.google.com with SMTP id d23so1106175fga.17
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 03:27:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A264B12.5030303@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2009 at 12:06:10PM +0200, Patrick McHardy wrote:
> Patrick McHardy wrote:
>>> PSCHED_SHIFT should be 4, right?
>>
>>> -#define    SM_SHIFT    20
>>> -#define    ISM_SHIFT    18
>>> +#define    PSCHED_SHIFT    6    /* TODO: move to pkt_sched.h */
>>> +#define    SM_SHIFT    (30 - PSCHED_SHIFT)
>>> +#define    ISM_SHIFT    (8 + PSCHED_SHIFT)
>>
>> Actually I'm confused, why the additional change of 10?
>
> OK, 10 - 6 = 4, got it :)
>

If you wanted to console me after my hfsc confusions, you did it!

Thanks again,
Jarek P.
