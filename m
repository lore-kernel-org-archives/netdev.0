From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V5 4/6 net-next] vhost: vhost TX zero-copy support
Date: Mon, 16 May 2011 23:45:40 +0300
Message-ID: <20110516204540.GD18148@redhat.com>
References: <1305574484.3456.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1305574484.3456.30.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> +/* Since we need to keep the order of used_idx as avail_idx, it's possible that
> + * DMA done not in order in lower device driver for some reason. To prevent
> + * used_idx out of order, upend_idx is used to track avail_idx order, done_idx
> + * is used to track used_idx order. Once lower device DMA done, then upend_idx
> + * can move to done_idx.

Could you clarify this please? virtio explicitly allows out of order
completion of requests. Does it simplify code that we try to keep
used index updates in-order? Because if not, this is not
really a requirement.

-- 
MST
