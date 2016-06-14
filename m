From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH v8 0/5] skb_array: array based FIFO for skbs
Date: Tue, 14 Jun 2016 13:56:59 +0200
Message-ID: <20160614135659.0cb9f2ff@redhat.com>
References: <20160613235426-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>,
	kvm@vger.kernel.org, brouer@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20160613235426-mutt-send-email-mst@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 13 Jun 2016 23:54:26 +0300 "Michael S. Tsirkin" <mst@redhat.com> wrote:
> 
> Jesper, Jason, I know that both of you tested this,
> please post Tested-by tags for whatever was tested.

Yes, I tested this via "external" kernel modules, not your framework.
I have verified that this V8 patchset is equivalent, to what I have in:
 https://github.com/netoptimizer/prototype-kernel/ (at 81ca09c2a945)

> changes since v7
> 	fix typos noticed by Jesper Brouer

You also fixed a missing _bh ... I verified you also included this fix ;-)
 https://github.com/netoptimizer/prototype-kernel/commit/24da4f495bb

> changes since v6
> 	resize implemented. peek/full calls are no longer lockless
> 
> 	replaced _FIELD macros with _CALL which invoke a function
> 	on the pointer rather than just returning a value
> 
> 	destroy now scans the array and frees all queued skbs
> 
> changes since v5
> 	implemented a generic ptr_ring api, and
> 		made skb_array a type-safe wrapper
> 	apis for taking the spinlock in different contexts
> 		following expected usecase in tun

Tested-by: Jesper Dangaard Brouer <brouer@redhat.com>

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
