From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: action stats broken?
Date: Sun, 21 Sep 2014 08:33:40 -0400
Message-ID: <541EC5A4.9040600@mojatatu.com>
References: <541D7E55.6070306@mojatatu.com> <541D9B78.8070505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john Fastabend <john.r.fastabend@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:32872 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaIUMdu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 08:33:50 -0400
Received: by mail-ig0-f182.google.com with SMTP id hn15so1356994igb.9
        for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 05:33:50 -0700 (PDT)
In-Reply-To: <541D9B78.8070505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/14 11:21, John Fastabend wrote:
> On 09/20/2014 06:17 AM, Jamal Hadi Salim wrote:

>
> I'm looking into it which classifier? A basic u32 classifier attached
> to the ingress qdisc seems to work. If your using u32 any hash tables,
> or 'filter change' commands before this?
>

Nothing that exciting.

> # tc actions add  action drop index 4
>
> # tc filter add dev p3p1 parent ffff:0 protocol ip prio 100 \
>      u32 match ip src 16.0.0.2 action gact index 4
>
> #tc -s actions ls action gact
>
>          action order 0: gact action drop
>           random type none pass val 0
>           index 4 ref 2 bind 1 installed 142 sec used 0 sec
>          Action statistics:
>          Sent 840 bytes 10 pkt (dropped 10, overlimits 0 requeues 0)
>          backlog 0b 0p requeues 0
>

Indeed that looks sane. What kernel version + iproute2?

I have time this morning - I will chase it to double check in case
my environment is messed up.

cheers,
jamal

>> cheers,
>> jamal
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
