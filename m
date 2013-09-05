From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Thu, 05 Sep 2013 13:16:16 +0800
Message-ID: <522813A0.1010507@redhat.com>
References: <1377816595.8277.54.camel@edumazet-glaptop>    <5226C4A0.6040709@redhat.com> <1378274376.7360.82.camel@edumazet-glaptop>   <5226D39C.9070401@redhat.com> <1378290638.7360.85.camel@edumazet-glaptop>  <5227F57D.7030709@redhat.com> <1378352479.11205.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40824 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754329Ab3IEFQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 01:16:31 -0400
In-Reply-To: <1378352479.11205.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/05/2013 11:41 AM, Eric Dumazet wrote:
> On Thu, 2013-09-05 at 11:07 +0800, Jason Wang wrote:
>
>> > tc -s -d qdisc
>> > qdisc fq 8001: dev eth0 root refcnt 2 [Unknown qdisc, optlen=64]
>> >  Sent 6680760347 bytes 4431855 pkt (dropped 0, overlimits 0 requeues 0)
>> >  backlog 0b 0p requeues 0
>> > 
>> > btw, is the fq support for tc merged into iproute2? Looks like I can't
>> > find them.
> Yep its there on net-next-3.11 branch

Thanks. With the tc in this branch, after test I get:

./tc -s -d qdisc
qdisc fq 8001: dev eth0 root refcnt 2 limit 10000p flow_limit 100p
buckets 1024 quantum 3028 initial_quantum 15140
 Sent 3545374119 bytes 2341785 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
  5 flows (0 inactive, 0 throttled)
  0 gc, 37 highprio, 51805 throttled
