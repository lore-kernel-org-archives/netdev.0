From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] virtio-net: move sg off stack
Date: Wed, 07 Apr 2010 21:01:51 -0700 (PDT)
Message-ID: <20100407.210151.45077626.davem@davemloft.net>
References: <20100404130741.GA7500@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, jpirko@redhat.com, xma@us.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100404130741.GA7500@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 4 Apr 2010 16:07:41 +0300

> Move sg structure off stack and into virtnet_info structure.
> This helps remove extra sg_init_table calls as well as reduce
> stack usage.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Tested-by: Michael S. Tsirkin <mst@redhat.com>

Applied to net-next-2.6, thanks Michael.
