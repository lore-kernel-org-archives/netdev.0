From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH] tun: use netif_receive_skb instead of netif_rx_ni
Date: Wed, 12 Feb 2014 13:50:53 +0800
Message-ID: <52FB0BBD.7060303@redhat.com>
References: <52FA32C5.9040601@huawei.com> <52FB066E.1020006@redhat.com> <1392184074.1752.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Qin Chuanyu <qinchuanyu@huawei.com>, davem@davemloft.net,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750922AbaBLFvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Feb 2014 00:51:22 -0500
In-Reply-To: <1392184074.1752.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/2014 01:47 PM, Eric Dumazet wrote:
> On Wed, 2014-02-12 at 13:28 +0800, Jason Wang wrote:
>
>> A question: without NAPI weight, could this starve other net devices?
> Not really, as net devices are serviced by softirq handler.
>
>

Yes, then the issue is tun could be starved by other net devices.
