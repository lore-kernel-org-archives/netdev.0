From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] sh_eth: check TSU registers ioremap() error
Date: Wed, 20 Mar 2013 22:45:45 +0300
Message-ID: <514A11E9.1070708@cogentembedded.com>
References: <201303200241.33137.sergei.shtylyov@cogentembedded.com> <20130320.122352.1542334118729356561.davem@davemloft.net> <514A0835.6070104@cogentembedded.com> <514A0B15.7000900@cogentembedded.com> <CAOJe8K2aoQLi0B4SaHEv0GPMe2g0YvuRQc1vwBZhLVJPZLsYCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nobuhiro.iwamatsu.yj@renesas.com
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:63116 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932756Ab3CTSo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 14:44:28 -0400
Received: by mail-la0-f44.google.com with SMTP id eb20so3608298lab.17
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 11:44:26 -0700 (PDT)
In-Reply-To: <CAOJe8K2aoQLi0B4SaHEv0GPMe2g0YvuRQc1vwBZhLVJPZLsYCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/20/2013 09:20 PM, Denis Kirjanov wrote:

> It doesn't make sense to worry about branch misprediction during probe() :)

     You misunderstood. I didn't mean using unlikely() at all, just that 
the ioremap() failure is unlikely.


PS: Please, don't top post.

> On 3/20/13, Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:
>> On 03/20/2013 10:04 PM, Sergei Shtylyov wrote:
>>
>>>>> One must check the result of ioremap() -- in this case it prevents
>>>>> potential
>>>>> kernel oops when initializing TSU registers further on...
>>>>>
>>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>>> Applied and queued up for -stable.
>>>     Thanks. However, do you really think it's needed in stable? It's
>>> only error path, after all...
>>      I forgot to add "unlikely" to the "error path". I usually don't mark
>> such patches for stable, when I'm not in a hurry. :-)
>>

WBR, Sergei
