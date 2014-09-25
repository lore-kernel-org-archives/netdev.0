From: Tom Herbert <therbert@google.com>
Subject: Re: [net-next PATCH 1/1 V4] qdisc: bulk dequeue support for qdiscs
 with TCQ_F_ONETXQUEUE
Date: Thu, 25 Sep 2014 07:40:33 -0700
Message-ID: <CA+mtBx8Nie9AiCG6iuY+EN7HiLAe-bxWpZxTpRhASmYabRUyFA@mail.gmail.com>
References: <20140924160932.9721.56450.stgit@localhost>
	<20140924161047.9721.43080.stgit@localhost>
	<1411579395.15395.41.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140924195831.6fb91051@redhat.com>
	<54234225.5000503@mojatatu.com>
	<20140925102505.494acab1@redhat.com>
	<54240F34.1050707@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	=?UTF-8?B?VG9rZSBIw7hpbGFuZC1Kw7hyZ2Vuc2Vu?= <toke@toke.dk>,
	Florian Westphal <fw@strlen.de>,
	Dave Taht <dave.taht@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:53704 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752983AbaIYOke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2014 10:40:34 -0400
Received: by mail-ie0-f172.google.com with SMTP id rp18so11871103iec.3
        for <netdev@vger.kernel.org>; Thu, 25 Sep 2014 07:40:33 -0700 (PDT)
In-Reply-To: <54240F34.1050707@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2014 at 5:48 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 09/25/14 04:25, Jesper Dangaard Brouer wrote:
>>
>> On Wed, 24 Sep 2014 18:13:57 -0400
>
>
>> I've done measurements with netperf-wrapper:
>>
>> http://netoptimizer.blogspot.dk/2014/09/mini-tutorial-for-netperf-wrapper-setup.html
>>
>> I have already previously posted my measurements here:
>>   http://people.netfilter.org/hawk/qdisc/
>>   http://people.netfilter.org/hawk/qdisc/measure01/
>>   http://people.netfilter.org/hawk/qdisc/experiment01/
>>
>
> Theres a lot of data there to digest; all good looking.
> I will try to pay attention to detail and get back to you.
> What you have on those urls is fit for a paper, but what someone
> like me (with ADD) needs is a summary somewhere maybe in the commit
> logs.
>
>> Please, see my previous mail where I described each graph.
>>
>
> Is this patch 0?
> I think a simple statement in the commit log that no cats
> were harmed ^W^W^W performance was affected. A paragraph
> at most but if you want to do more, DaveM actually has no
> problems if you write the details of a novel in patch 0.
>
+1

A few test results in patch 0 are good. I like to have results for
with and without patch. These should two things: 1) Any regressions
caused by the patch 2) Performance gains (in that order of importance
:-) ). There doesn't need to be a lot here, just something reasonably
representative, simple, and should be easily reproducible. My
expectation in bulk dequeue is that we should see no obvious
regression and hopefully an improvement in CPU utilization-- are you
able to verify this?


> cheers,
> jamal
