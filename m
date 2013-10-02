From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netif_set_xps_queue: make cpu mask const
Date: Wed, 02 Oct 2013 17:07:57 -0400 (EDT)
Message-ID: <20131002.170757.855953378869304259.davem@davemloft.net>
References: <20131002061406.GA8809@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, rusty@rustcorp.com.au, edumazet@google.com,
	jiri@resnulli.us, vyasevic@redhat.com, amwang@redhat.com,
	alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131002061406.GA8809@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Wed, 2 Oct 2013 09:14:06 +0300

> virtio wants to pass in cpumask_of(cpu), make parameter
> const to avoid build warnings.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Refresh my memory, is to accomodate a change you want to submit to
'net' or 'net-next'?  This patch only applies to 'net' cleanly.
