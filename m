From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V5 4/6 net-next] vhost: vhost TX zero-copy support
Date: Tue, 17 May 2011 08:34:04 -0700
Message-ID: <1305646444.10756.16.camel@localhost.localdomain>
References: <1305574484.3456.30.camel@localhost.localdomain>
	 <20110516204540.GD18148@redhat.com>
	 <1305579414.3456.49.camel@localhost.localdomain>
	 <20110516212401.GF18148@redhat.com>
	 <1305606683.10756.3.camel@localhost.localdomain>
	 <20110517055503.GA26989@redhat.com>
	 <1305645734.10756.14.camel@localhost.localdomain>
	 <20110517152840.GA2389@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110517152840.GA2389@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-05-17 at 18:28 +0300, Michael S. Tsirkin wrote:
> Which is the order the descriptors are put on avail ring.
> By design, guest should not depend on used ring entries
> being in order with avail ring (and btw with virtio block,
> they aren't). If it does, it's a bug I think.

Ok, I thought, the order should be maintained.

> > The original code has no problem, because it gets one head and pass
> that
> > head to vhost_add_used one by one once done the copy. So it's in
> > sequence.
> > 
> > This issue can easily recreate without zerocopy patch by simply
> changing
> > the order from "head return vhost_get_vq_desc" when passing to
> > vhost_add_used.
> > 
> > Thanks
> > Shirley
> 
> Ah, did you try that? Could you post this patch pls?
> This seems to imply a bug in guest virtio. 

I am creating the patch against net-next for you to test today.

Thanks
Shirley
