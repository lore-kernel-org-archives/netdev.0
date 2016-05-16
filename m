From: Dave Taht <dave.taht@gmail.com>
Subject: Re: OpenWRT wrong adjustment of fq_codel defaults (Was: [Codel]
 fq_codel_drop vs a udp flood)
Date: Mon, 16 May 2016 09:04:01 -0700
Message-ID: <CAA93jw7=FRhj+oZ8LT0Oxn2Lb3YFL-u5yZr7mi8bc2HZWzLxvg@mail.gmail.com>
References: <CAA93jw6QLyx9EaS+ntB0D3duoysu_Z-UYyQfHnRa=pfqPDfWOw@mail.gmail.com>
	<1462125592.5535.194.camel@edumazet-glaptop3.roam.corp.google.com>
	<865DA393-262D-40B6-A9D3-1B978CD5F6C6@gmail.com>
	<1462128385.5535.200.camel@edumazet-glaptop3.roam.corp.google.com>
	<C5D365DA-18EE-446E-9D25-41F48B1C583E@gmail.com>
	<1462136140.5535.219.camel@edumazet-glaptop3.roam.corp.google.com>
	<CACiydbKUu11=zWitkDha0ddgk1-G_Z4-e1+=9ky776VktF5HHg@mail.gmail.com>
	<1462201620.5535.250.camel@edumazet-glaptop3.roam.corp.google.com>
	<CACiydbKeKUENncrc-NmYRcku-DGVeGqqzYMqsCqKdxPsR7yUOQ@mail.gmail.com>
	<1462205669.5535.254.camel@edumazet-glaptop3.roam.corp.google.com>
	<CACiydbL26Jj3EcEL4EmqaH=1Dm-Q0dpVwoWxqUSZ7ry10bRgeg@mail.gmail.com>
	<1462464776.13075.18.camel@edumazet-glaptop3.roam.corp.google.com>
	<CACiydbJYrFRMJvSHM6tJYWR8vmgV3xxnSUQsb-h5WcnLW=KXoQ@mail.gmail.com>
	<1462476207.13075.20.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160506114243.4eb4f95e@redhat.com>
	<20160506144740.210901f5@redhat.com>
	<CACiydbL3qZrvZ4a_OUXiN0dp7qdqOktaQdAUdfOpKkZ1OfEZbA@mail.gmail.com>
	<CACiydb+A_vFNdp7tbw67Rnp+kHwt5GsLa+Su+pO8YmOZYp_KHg@mail.gmail.com>
	<CAA93jw4XeMSxiTLHWZ2b=F9ni7wz9RpkWDdhTh99gn4Mf1aWjA@mail.gmail.com>
	<CACiydbLcYe=2VLb3W9i-i2FGALwxJK=oO8RcZWjmj3YPGObK3Q@mail.gmail.com>
	<CACiydbJWY7xK1tj1Q-umdSNkTy9V+HYQ6SeOxihMASwr1zcApg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rajkumar Manoharan <rmanohar@codeaurora.org>,
	Michal Kazior <michal.kazior@tieto.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Felix Fietkau <nbd@nbd.name>,
	Jonathan Morton <chromatix99@gmail.com>,
	"codel@lists.bufferbloat.net" <codel@lists.bufferbloat.net>,
	ath10k <ath10k@lists.infradead.org>,
	make-wifi-fast@lists.bufferbloat.net,
	=?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	OpenWrt Development List <openwrt-devel@lists.openwrt.org>
To: Roman Yeryomin <leroi.lists@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:34710 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654AbcEPQEE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 12:04:04 -0400
Received: by mail-oi0-f47.google.com with SMTP id k142so275146414oib.1
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 09:04:03 -0700 (PDT)
In-Reply-To: <CACiydbJWY7xK1tj1Q-umdSNkTy9V+HYQ6SeOxihMASwr1zcApg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2016 at 1:14 AM, Roman Yeryomin <leroi.lists@gmail.com>=
 wrote:
> On 16 May 2016 at 01:34, Roman Yeryomin <leroi.lists@gmail.com> wrote=
:
>> On 6 May 2016 at 22:43, Dave Taht <dave.taht@gmail.com> wrote:
>>> On Fri, May 6, 2016 at 11:56 AM, Roman Yeryomin <leroi.lists@gmail.=
com> wrote:
>>>> On 6 May 2016 at 21:43, Roman Yeryomin <leroi.lists@gmail.com> wro=
te:
>>>>> On 6 May 2016 at 15:47, Jesper Dangaard Brouer <brouer@redhat.com=
> wrote:
>>>>>>
>>>>>> I've created a OpenWRT ticket[1] on this issue, as it seems that=
 someone[2]
>>>>>> closed Felix'es OpenWRT email account (bad choice! emails bounci=
ng).
>>>>>> Sounds like OpenWRT and the LEDE https://www.lede-project.org/ p=
roject
>>>>>> is in some kind of conflict.
>>>>>>
>>>>>> OpenWRT ticket [1] https://dev.openwrt.org/ticket/22349
>>>>>>
>>>>>> [2] http://thread.gmane.org/gmane.comp.embedded.openwrt.devel/40=
298/focus=3D40335
>>>>>
>>>>> OK, so, after porting the patch to 4.1 openwrt kernel and playing=
 a
>>>>> bit with fq_codel limits I was able to get 420Mbps UDP like this:
>>>>> tc qdisc replace dev wlan0 parent :1 fq_codel flows 16 limit 256
>>>>
>>>> Forgot to mention, I've reduced drop_batch_size down to 32
>>>
>>> 0) Not clear to me if that's the right line, there are 4 wifi queue=
s,
>>> and the third one
>>> is the BE queue.
>>
>> That was an example, sorry, should have stated that. I've applied sa=
me
>> settings to all 4 queues.
>>
>>> That is too low a limit, also, for normal use. And:
>>> for the purpose of this particular UDP test, flows 16 is ok, but no=
t
>>> ideal.
>>
>> I played with different combinations, it doesn't make any
>> (significant) difference: 20-30Mbps, not more.
>> What numbers would you propose?
>>
>>> 1) What's the tcp number (with a simultaneous ping) with this lates=
t patchset?
>>> (I care about tcp performance a lot more than udp floods - survivin=
g a
>>> udp flood yes, performance, no)
>>
>> During the test (both TCP and UDP) it's roughly 5ms in average, not
>> running tests ~2ms. Actually I'm now wondering if target is working =
at
>> all, because I had same result with target 80ms..
>> So, yes, latency is good, but performance is poor.
>>
>>> before/after?
>>>
>>> tc -s qdisc show dev wlan0 during/after results?
>>
>> during the test:
>>
>> qdisc mq 0: root
>>  Sent 1600496000 bytes 1057194 pkt (dropped 1421568, overlimits 0 re=
queues 17)
>>  backlog 1545794b 1021p requeues 17
>> qdisc fq_codel 8001: parent :1 limit 1024p flows 16 quantum 1514
>> target 80.0ms ce_threshold 32us interval 100.0ms ecn
>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>  backlog 0b 0p requeues 0
>>   maxpacket 0 drop_overlimit 0 new_flow_count 0 ecn_mark 0
>>   new_flows_len 0 old_flows_len 0
>> qdisc fq_codel 8002: parent :2 limit 1024p flows 16 quantum 1514
>> target 80.0ms ce_threshold 32us interval 100.0ms ecn
>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>  backlog 0b 0p requeues 0
>>   maxpacket 0 drop_overlimit 0 new_flow_count 0 ecn_mark 0
>>   new_flows_len 0 old_flows_len 0
>> qdisc fq_codel 8003: parent :3 limit 1024p flows 16 quantum 1514
>> target 80.0ms ce_threshold 32us interval 100.0ms ecn
>>  Sent 1601271168 bytes 1057706 pkt (dropped 1422304, overlimits 0 re=
queues 17)
>>  backlog 1541252b 1018p requeues 17
>>   maxpacket 1514 drop_overlimit 1422304 new_flow_count 35 ecn_mark 0
>>   new_flows_len 0 old_flows_len 1
>> qdisc fq_codel 8004: parent :4 limit 1024p flows 16 quantum 1514
>> target 80.0ms ce_threshold 32us interval 100.0ms ecn
>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>  backlog 0b 0p requeues 0
>>   maxpacket 0 drop_overlimit 0 new_flow_count 0 ecn_mark 0
>>   new_flows_len 0 old_flows_len 0
>>
>>
>> after the test (60sec):
>>
>> qdisc mq 0: root
>>  Sent 3084996052 bytes 2037744 pkt (dropped 2770176, overlimits 0 re=
queues 28)
>>  backlog 0b 0p requeues 28
>> qdisc fq_codel 8001: parent :1 limit 1024p flows 16 quantum 1514
>> target 80.0ms ce_threshold 32us interval 100.0ms ecn
>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>  backlog 0b 0p requeues 0
>>   maxpacket 0 drop_overlimit 0 new_flow_count 0 ecn_mark 0
>>   new_flows_len 0 old_flows_len 0
>> qdisc fq_codel 8002: parent :2 limit 1024p flows 16 quantum 1514
>> target 80.0ms ce_threshold 32us interval 100.0ms ecn
>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>  backlog 0b 0p requeues 0
>>   maxpacket 0 drop_overlimit 0 new_flow_count 0 ecn_mark 0
>>   new_flows_len 0 old_flows_len 0
>> qdisc fq_codel 8003: parent :3 limit 1024p flows 16 quantum 1514
>> target 80.0ms ce_threshold 32us interval 100.0ms ecn
>>  Sent 3084996052 bytes 2037744 pkt (dropped 2770176, overlimits 0 re=
queues 28)
>>  backlog 0b 0p requeues 28
>>   maxpacket 1514 drop_overlimit 2770176 new_flow_count 64 ecn_mark 0
>>   new_flows_len 0 old_flows_len 1
>> qdisc fq_codel 8004: parent :4 limit 1024p flows 16 quantum 1514
>> target 80.0ms ce_threshold 32us interval 100.0ms ecn
>>  Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>>  backlog 0b 0p requeues 0
>>   maxpacket 0 drop_overlimit 0 new_flow_count 0 ecn_mark 0
>>   new_flows_len 0 old_flows_len 0
>>
>>
>>> IF you are doing builds for the archer c7v2, I can join in on this.=
=2E. (?)
>>
>> I'm not but I have c7 somewhere, so I can do a build for it and also
>> test, so we are on the same page.
>>
>>> I did do a test of the ath10k "before", fq_codel *never engaged*, a=
nd
>>> tcp induced latencies under load, e at 100mbit, cracked 600ms, whil=
e
>>> staying flat (20ms) at 100mbit. (not the same patches you are testi=
ng)
>>> on x86. I have got tcp 300Mbit out of an osx box, similar latency,
>>> have yet to get anything more on anything I currently have
>>> before/after patchsets.
>>>
>>> I'll go add flooding to the tests, I just finished a series compari=
ng
>>> two different speed stations and life was good on that.
>>>
>>> "before" - fq_codel never engages, we see seconds of latency under =
load.
>>>
>>> root@apu2:~# tc -s qdisc show dev wlp4s0
>>> qdisc mq 0: root
>>>  Sent 8570563893 bytes 6326983 pkt (dropped 0, overlimits 0 requeue=
s 0)
>>>  backlog 0b 0p requeues 0
>>> qdisc fq_codel 0: parent :1 limit 10240p flows 1024 quantum 1514
>>> target 5.0ms interval 100.0ms ecn
>>>  Sent 2262 bytes 17 pkt (dropped 0, overlimits 0 requeues 0)
>>>  backlog 0b 0p requeues 0
>>>   maxpacket 0 drop_overlimit 0 new_flow_count 0 ecn_mark 0
>>>   new_flows_len 0 old_flows_len 0
>>> qdisc fq_codel 0: parent :2 limit 10240p flows 1024 quantum 1514
>>> target 5.0ms interval 100.0ms ecn
>>>  Sent 220486569 bytes 152058 pkt (dropped 0, overlimits 0 requeues =
0)
>>>  backlog 0b 0p requeues 0
>>>   maxpacket 18168 drop_overlimit 0 new_flow_count 1 ecn_mark 0
>>>   new_flows_len 0 old_flows_len 1
>>> qdisc fq_codel 0: parent :3 limit 10240p flows 1024 quantum 1514
>>> target 5.0ms interval 100.0ms ecn
>>>  Sent 8340546509 bytes 6163431 pkt (dropped 0, overlimits 0 requeue=
s 0)
>>>  backlog 0b 0p requeues 0
>>>   maxpacket 68130 drop_overlimit 0 new_flow_count 120050 ecn_mark 0
>>>   new_flows_len 1 old_flows_len 3
>>> qdisc fq_codel 0: parent :4 limit 10240p flows 1024 quantum 1514
>>> target 5.0ms interval 100.0ms ecn
>>>  Sent 9528553 bytes 11477 pkt (dropped 0, overlimits 0 requeues 0)
>>>  backlog 0b 0p requeues 0
>>>   maxpacket 66 drop_overlimit 0 new_flow_count 1 ecn_mark 0
>>>   new_flows_len 1 old_flows_len 0
>>>   ```
>>>
>>>
>>>>> This is certainly better than 30Mbps but still more than two time=
s
>>>>> less than before (900).
>>>
>>> The number that I still am not sure we got is that you were sending
>>> 900mbit udp and recieving 900mbit on the prior tests?
>>
>> 900 was sending, AP POV (wifi client is downloading)
>>
>>>>> TCP also improved a little (550 to ~590).
>>>
>>> The limit is probably a bit low, also.  You might want to try targe=
t
>>> 20ms as well.
>>
>> I've tried limit up to 1024 and target up to 80ms
>>
>>>>>
>>>>> Felix, others, do you want to see the ported patch, maybe I did s=
omething wrong?
>>>>> Doesn't look like it will save ath10k from performance regression=
=2E
>>>
>>> what was tcp "before"? (I'm sorry, such a long thread)
>>
>> 750Mbps
>
> Michal, after retesting with your patch (sorry, it was late yesterday=
,
> confused compat-wireless archives) I saw the difference.
> So the progress looks like this (all with fq_codel flows 16 limit 102=
4
> target 20ms):
> no patches: 380Mbps UDP, 550 TCP
> Eric's (fq_codel drop) patch: 420Mbps UDP, 590 TCP (+40Mbps), latency
> 5-6ms during test
> Michal's (improve tx scheduling) patch: 580Mbps UDP, 660 TCP, latency
> up to 30-40ms during test
> after Rajkumar's proposal to "try without registering wake_tx_queue
> callback": 820Mbps UDP, 690 TCP.

And the simultaneous ping on the last test was?

> So, very close to "as before": 900Mbps UDP, 750 TCP.
> But still, I was expecting performance improvements from latest ath10=
k
> code, not regressions.
> I know that hw is capable of 800Mbps TCP, which I'm targeting.
>
> Regards,
> Roman
>
> p.s. sorry for confusion



--=20
Dave T=C3=A4ht
Let's go make home routers and wifi faster! With better software!
http://blog.cerowrt.org
