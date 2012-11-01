From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 1/8] skb: report completion status for zero
 copy skbs
Date: Thu, 01 Nov 2012 11:50:24 -0400 (EDT)
Message-ID: <20121101.115024.1422610516561380154.davem@davemloft.net>
References: <cover.1351679008.git.mst@redhat.com>
	<0dc176ed796ff5ac7164b6c18cc75d64c2a2317e.1351679008.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, edumazet@google.com,
	akpm@linux-foundation.org, alexander.h.duyck@intel.com,
	Ian.Campbell@citrix.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <0dc176ed796ff5ac7164b6c18cc75d64c2a2317e.1351679008.git.mst@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 31 Oct 2012 12:31:06 +0200

> -void vhost_zerocopy_callback(struct ubuf_info *ubuf)
> +void vhost_zerocopy_callback(struct ubuf_info *ubuf, int zerocopy_status)

If you're only reporting true/false values, even just for now,
please use 'bool' for this.
