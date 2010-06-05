From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] skbuff: add check for non-linear to
 warn_if_lro and needs_linearize
Date: Sat, 05 Jun 2010 02:54:23 -0700 (PDT)
Message-ID: <20100605.025423.258132771.davem@davemloft.net>
References: <20100602222230.12962.97260.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com,
	x86@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100602222230.12962.97260.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 02 Jun 2010 15:24:37 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> We can avoid an unecessary cache miss by checking if the skb is non-linear
> before accessing gso_size/gso_type in skb_warn_if_lro, the same can also be
> done to avoid a cache miss on nr_frags if data_len is 0.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
