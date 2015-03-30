From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH RFC v2 1/2] can: fix multiple delivery of a single CAN
 frame for overlapping CAN filters
Date: Mon, 30 Mar 2015 19:25:04 +0200
Message-ID: <551986F0.8010609@hartkopp.net>
References: <1427652564-32181-1-git-send-email-socketcan@hartkopp.net> <1427652564-32181-2-git-send-email-socketcan@hartkopp.net> <5519429A.8050000@cogentembedded.com> <5519708E.3040002@hartkopp.net> <55198485.5070107@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <55198485.5070107@cogentembedded.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.03.2015 19:14, Sergei Shtylyov wrote:
> On 03/30/2015 06:49 PM, Oliver Hartkopp wrote:
>
>>>> +    /* eliminate multiple filter matches for the same skb */
>>>> +    if (*this_cpu_ptr(ro->uniq_skb) == oskb &&
>>>> +        ktime_equal(*this_cpu_ptr(ro->uniq_tstamp), oskb->tstamp)) {
>>>> +            return;
>
>>>     Over-indented.
>
>> I was asked about that before. AFAIK the *skb is no unique identifier over a
>> longer period of time. But together with the timestamp it becomes unique.
>> Or do you have a better solution to detect identical skbs?
>
>     I just said that *return* was too far to the right, that's all. :-)

Oh, ok ...

I mixed indented with intended %-)

My bad.

Will fix that in v3 too.

Good thing: So far no one complained about the __percpu stuff ...

Many thanks,
Oliver

