From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Thu, 05 Sep 2013 11:39:36 +0800
Message-ID: <5227FCF8.8020504@redhat.com>
References: <1377816595.8277.54.camel@edumazet-glaptop>  <5226C4A0.6040709@redhat.com> <1378274376.7360.82.camel@edumazet-glaptop>  <5226D39C.9070401@redhat.com> <1378290638.7360.85.camel@edumazet-glaptop> <1378294029.7360.92.camel@edumazet-glaptop> <5227209F.4060708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>, KVM <kvm@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <5227209F.4060708@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/04/2013 07:59 PM, Daniel Borkmann wrote:
> On 09/04/2013 01:27 PM, Eric Dumazet wrote:
>> On Wed, 2013-09-04 at 03:30 -0700, Eric Dumazet wrote:
>>> On Wed, 2013-09-04 at 14:30 +0800, Jason Wang wrote:
>>>
>>>>> And tcpdump would certainly help ;)
>>>>
>>>> See attachment.
>>>>
>>>
>>> Nothing obvious on tcpdump (only that lot of frames are missing)
>>>
>>> 1) Are you capturing part of the payload only (like tcpdump -s 128)
>>>
>>> 2) What is the setup.
>>>
>>> 3) tc -s -d qdisc
>>
>> If you use FQ in the guest, then it could be that high resolution timers
>> have high latency ?
>
> Probably they internally switch to a lower resolution clock event
> source if
> there's no hardware support available:
>
>   The [source event] management layer provides interfaces for hrtimers to
>   implement high resolution timers [...] [and it] supports these more
> advanced
>   functions only when appropriate clock event sources have been
> registered,
>   otherwise the traditional periodic tick based behaviour is retained.
> [1]
>
> [1] https://www.kernel.org/doc/ols/2006/ols2006v1-pages-333-346.pdf 

Maybe, AFAIK, kvm-clock does not provide a clock event, only a pv
clocksource were provided.
