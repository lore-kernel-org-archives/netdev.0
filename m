From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH v2 1/4] Defer skb allocation -- add destroy buffers
 function for virtio
Date: Mon, 14 Dec 2009 15:22:22 -0800
Message-ID: <1260832942.4387.9.camel@localhost.localdomain>
References: <1258697359.7416.14.camel@localhost.localdomain>
	 <200911231123.18898.rusty@rustcorp.com.au>
	 <20091208122134.GA17286@redhat.com>
	 <1260534506.30371.6.camel@localhost.localdomain>
	 <1260534805.30371.10.camel@localhost.localdomain>
	 <20091213102632.GB6789@redhat.com>
	 <1260821285.8716.7.camel@localhost.localdomain>
	 <20091214202253.GG6150@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Anthony Liguori <anthony@codemonkey.ws>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932925AbZLNXW3@vger.kernel.org>
In-Reply-To: <20091214202253.GG6150@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Michael,

On Mon, 2009-12-14 at 22:22 +0200, Michael S. Tsirkin wrote:
> I dont insist, but my idea was
> 
> for (;;) {
>         b = vq->destroy(vq);
>         if (!b)
>                 break;
>         --vi->num;
>         put_page(b);
> }
> 
> so we do not have to lose track of the counter.

That's not a bad idea, but to do this, then this fuction will be
specific for virtio_net device (vi is virtnet_info) only in a generic
virtqueue API.

Thanks
Shirley
