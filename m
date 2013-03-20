From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: Re: [PATCH 2/2] sh_eth: check TSU registers ioremap() error
Date: Wed, 20 Mar 2013 22:20:35 +0400
Message-ID: <CAOJe8K2aoQLi0B4SaHEv0GPMe2g0YvuRQc1vwBZhLVJPZLsYCQ@mail.gmail.com>
References: <201303200241.33137.sergei.shtylyov@cogentembedded.com>
	<20130320.122352.1542334118729356561.davem@davemloft.net>
	<514A0835.6070104@cogentembedded.com>
	<514A0B15.7000900@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f52.google.com ([209.85.219.52]:56060 "EHLO
	mail-oa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223Ab3CTSUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 14:20:36 -0400
Received: by mail-oa0-f52.google.com with SMTP id k14so2098959oag.25
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 11:20:35 -0700 (PDT)
In-Reply-To: <514A0B15.7000900@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It doesn't make sense to worry about branch misprediction during probe() :)

On 3/20/13, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
> On 03/20/2013 10:04 PM, Sergei Shtylyov wrote:
>
>>
>>>
>>>> One must check the result of ioremap() -- in this case it prevents
>>>> potential
>>>> kernel oops when initializing TSU registers further on...
>>>>
>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>> Applied and queued up for -stable.
>>
>>    Thanks. However, do you really think it's needed in stable? It's
>> only error path, after all...
>
>     I forgot to add "unlikely" to the "error path". I usually don't mark
> such patches for stable, when I'm not in a hurry. :-)
>
> WBR, Sergei
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
