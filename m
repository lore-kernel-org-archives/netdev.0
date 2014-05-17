From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: ethernet: mellanox: mlx4: let mlx4
 depend on SMP
Date: Sat, 17 May 2014 01:36:55 -0400 (EDT)
Message-ID: <20140517.013655.349586284786993619.davem@davemloft.net>
References: <5376F2F8.3010603@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	gxt@mprc.pku.edu.cn, matanb@mellanox.com, ogerlitz@mellanox.com,
	eyalpe@mellanox.com, amirv@mellanox.com, sbohrer@rgmadvisors.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: gang.chen.5i5j@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5376F2F8.3010603@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chen Gang <gang.chen.5i5j@gmail.com>
Date: Sat, 17 May 2014 13:26:16 +0800

> 'struct irq_affinity_notify' and the related functions are only defined
> when SMP enabled, so at present, mlx4 has to only run under SMP.
> 
> The related error (allmodconfig under unicore32):

Making the entire driver depend upon SMP is not the answer,
other Mellanox developers said that a proper fix is pending
so please be patient.
