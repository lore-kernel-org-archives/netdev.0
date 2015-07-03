From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 6/6] net_sched: act: remove spinlock in fast
 path
Date: Fri, 03 Jul 2015 10:21:36 -0700
Message-ID: <5596C4A0.9030502@gmail.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com>	 <1435842455-30501-7-git-send-email-edumazet@google.com>	 <5595684D.90500@gmail.com>	 <1435870750.11970.37.camel@edumazet-glaptop2.roam.corp.google.com>	 <55967137.7080806@mojatatu.com> <1435925285.11970.69.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f180.google.com ([209.85.214.180]:36671 "EHLO
	mail-ob0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755289AbbGCRVm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 13:21:42 -0400
Received: by obdbs4 with SMTP id bs4so72922867obd.3
        for <netdev@vger.kernel.org>; Fri, 03 Jul 2015 10:21:41 -0700 (PDT)
In-Reply-To: <1435925285.11970.69.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-03 05:08 AM, Eric Dumazet wrote:
> On Fri, 2015-07-03 at 07:25 -0400, Jamal Hadi Salim wrote:
>> On 07/02/15 16:59, Eric Dumazet wrote:
>>> On Thu, 2015-07-02 at 09:35 -0700, John Fastabend wrote:
>>
>>>
>>> Point is to not dirty cache line for every packet ?
>>>
>>> Doing the test means we attempt dirtying only ~HZ times per second,
>>> which really matters to handle millions of packets per second.
>>>
>>> My tests show a good enough performance, not sure we want a percpu thing
>>> for this lastuse field.

Agreed percpu is overkill thanks for the explanation. Looks good
to me.
