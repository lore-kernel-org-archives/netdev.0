From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH -next v3] net: core: set qdisc pkt len before tc_classify
Date: Wed, 13 May 2015 20:10:08 -0400
Message-ID: <5553E7E0.8040107@mojatatu.com>
References: <1431556588-4859-1-git-send-email-fw@strlen.de> <20150513235436.GA4851@Alexeis-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:34777 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbbENAKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 20:10:16 -0400
Received: by iecmd7 with SMTP id md7so47162936iec.1
        for <netdev@vger.kernel.org>; Wed, 13 May 2015 17:10:16 -0700 (PDT)
In-Reply-To: <20150513235436.GA4851@Alexeis-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/13/15 19:54, Alexei Starovoitov wrote:
> On Thu, May 14, 2015 at 12:36:28AM +0200, Florian Westphal wrote:
>> commit d2788d34885d4ce5ba ("net: sched: further simplify handle_ing")
>> removed the call to qdisc_enqueue_root().
>>
>> However, after this removal we no longer set qdisc pkt length.
>> This breaks traffic policing on ingress.
>>
>> This is the minimum fix: set qdisc pkt length before tc_classify.
>
> Thanks!
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>
>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal

PS:- dont agree with the statement that policer is rarely used
on ingress.
