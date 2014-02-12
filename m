From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tun: use netif_receive_skb instead of netif_rx_ni
Date: Tue, 11 Feb 2014 21:47:54 -0800
Message-ID: <1392184074.1752.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <52FA32C5.9040601@huawei.com> <52FB066E.1020006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Qin Chuanyu <qinchuanyu@huawei.com>, davem@davemloft.net,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Anthony Liguori <anthony@codemonkey.ws>,
	KVM list <kvm@vger.kernel.org>, netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <52FB066E.1020006@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-02-12 at 13:28 +0800, Jason Wang wrote:

> A question: without NAPI weight, could this starve other net devices?

Not really, as net devices are serviced by softirq handler.


