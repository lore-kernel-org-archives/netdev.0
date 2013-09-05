From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Thu, 05 Sep 2013 11:07:41 +0800
Message-ID: <5227F57D.7030709@redhat.com>
References: <1377816595.8277.54.camel@edumazet-glaptop>   <5226C4A0.6040709@redhat.com> <1378274376.7360.82.camel@edumazet-glaptop>  <5226D39C.9070401@redhat.com> <1378290638.7360.85.camel@edumazet-glaptop>
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
Received: from mx1.redhat.com ([209.132.183.28]:36113 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935524Ab3IEDHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Sep 2013 23:07:53 -0400
In-Reply-To: <1378290638.7360.85.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2013 06:30 PM, Eric Dumazet wrote:
> On Wed, 2013-09-04 at 14:30 +0800, Jason Wang wrote:
>
>>> And tcpdump would certainly help ;)
>> See attachment.
>>
> Nothing obvious on tcpdump (only that lot of frames are missing)
>
> 1) Are you capturing part of the payload only (like tcpdump -s 128)

No, I use something like tcpdump -i eth0 -w fq -c 300 after the netperf
start.
>
> 2) What is the setup.

Tow kvm guest with virtio-net and vhost enabled. Only one queue is
enabled and the guest were connected with bridge. Both host and guest
were net-next.git
>
> 3) tc -s -d qdisc

tc -s -d qdisc
qdisc fq 8001: dev eth0 root refcnt 2 [Unknown qdisc, optlen=64]
 Sent 6680760347 bytes 4431855 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0

btw, is the fq support for tc merged into iproute2? Looks like I can't
find them.
>
>
>
>
