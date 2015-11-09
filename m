From: Tom Herbert <tom@herbertland.com>
Subject: Re: linux-next network throughput performance regression
Date: Sun, 8 Nov 2015 21:30:29 -0800
Message-ID: <CALx6S34iGMPYF9AaHNNjtK03PXjTrW-Pxq6eFUwusoa=TbJsGQ@mail.gmail.com>
References: <6c0fed5fc63a4c3488f5f08409f508ee@HKXPR30MB0039.064d.mgd.msft.net>
	<20151108.215247.1161049251544860672.davem@davemloft.net>
	<eaea78c44de44abcb7936ab070f1b09d@HKXPR30MB0039.064d.mgd.msft.net>
	<20151108.222343.882542189870767346.davem@davemloft.net>
	<948e8dc00b4a4b6894111a17eaf89b03@HKXPR30MB0039.064d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"dsa@cumulusnetworks.com" <dsa@cumulusnetworks.com>,
	Simon Xiao <sixiao@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>
To: Dexuan Cui <decui@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <948e8dc00b4a4b6894111a17eaf89b03@HKXPR30MB0039.064d.mgd.msft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 8, 2015 at 7:31 PM, Dexuan Cui <decui@microsoft.com> wrote:
>> From: David Miller [mailto:davem@davemloft.net]
>> Sent: Monday, November 9, 2015 11:24
>> ...
>> > Thanks, David!
>> > I understand 1 TX queue is the bottleneck (however in Simon's
>> > test, TX=1 => 36.7Gb/s, TX=8 => 37.7 Gb/s, so it looks the TX=1 bottleneck
>> > is not so obvious).
>> > I'm just wondering how the bottleneck became much narrower with
>> > recent linux-next in Simon's result (36.7 Gb/s vs. 18.2 Gb/s). IMO there
>> > must be some latency somewhere.
>>
>> I think the whole thing here is that you misinterpreted what Eric said.
>>
>> He is not arguing that some regression did, or did not, happen.
>>
>> He instead was making the basic statement about the fact that due to
>> the lack of paralellness a single stream TCP case is harder to
>> optimize for high speed NICs.
>>
>> That is all.
> Thanks, I got it.
> I'm actually new to network performance tuning, trying to understand
> all the related details. :-)
>

You might want to look at
https://www.kernel.org/doc/Documentation/networking/scaling.txt as an
introduction to the scaling capabilities of the stack.

Tom

> Thanks,
> -- Dexuan
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
