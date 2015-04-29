From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] mlx4: Fix tx ring affinity_mask creation
Date: Wed, 29 Apr 2015 15:17:26 -0400 (EDT)
Message-ID: <20150429.151726.2104003118383475913.davem@davemloft.net>
References: <1430257769-23350-1-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, idos@mellanox.com, gerlitz.or@gmail.com,
	clsoto@us.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bpoirier@suse.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430257769-23350-1-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Poirier <bpoirier@suse.de>
Date: Tue, 28 Apr 2015 14:49:29 -0700

> By default, the number of tx queues is limited by the number of online cpus
> in mlx4_en_get_profile(). However, this limit no longer holds after the
> ethtool .set_channels method has been called. In that situation, the driver
> may access invalid bits of certain cpumask variables when queue_index >=
> nr_cpu_ids.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> Acked-by: Ido Shamay <idos@mellanox.com>
> Fixes: d03a68f ("net/mlx4_en: Configure the XPS queue mapping on driver load")

Applied and queue up for -stable, thanks.
