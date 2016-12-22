From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] net, sched: fix soft lockup in tc_classify
Date: Fri, 23 Dec 2016 00:21:39 +0100
Message-ID: <585C6003.9050806@iogearbox.net>
References: <585ADFEB.3030206@iogearbox.net> <CAM_iQpUEUmJpjQYV7HV+4NVtGe6D-yZs6=YizcDtf7dogkNR0Q@mail.gmail.com> <585AEF24.4070800@iogearbox.net> <20161222.115326.376675148706578174.davem@davemloft.net> <585C127E.7040509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, shahark@mellanox.com,
        gerlitz.or@gmail.com, roid@mellanox.com, jiri@mellanox.com,
        netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36461 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761800AbcLVXVn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 18:21:43 -0500
In-Reply-To: <585C127E.7040509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/22/2016 06:50 PM, John Fastabend wrote:
> On 16-12-22 08:53 AM, David Miller wrote:
>> From: Daniel Borkmann <daniel@iogearbox.net>
>> Date: Wed, 21 Dec 2016 22:07:48 +0100
>>
>>> Ok, you mean for net. In that case I prefer the smaller sized fix to
>>> be honest. It also covers everything from the point where we fetch
>>> the chain via cops->tcf_chain() to the end of the function, which is
>>> where most of the complexity resides, and only the two mentioned
>>> commits do the relock, so as a fix I think it's fine as-is. As
>>> mentioned, if there's need to refactor tc_ctl_tfilter() net-next
>>> would be better, imho.
>>
>> Please, can you two work towards an agreement as to what fix should
>> go in at this time?
>>
>> Thanks.
>
> Thanks for fixing this!
>
> I have a slight preference to push this patch into net as its been
> tested already by Shahar and is not particularly invasive. Then for
> net-next do a larger cleanup to get rid of some of the complexity per
> Cong's suggestion.

My preference as well, thanks.
