From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Sun, 07 Feb 2010 19:40:22 -0800 (PST)
Message-ID: <20100207.194022.53074897.davem@davemloft.net>
References: <20100208132243.ab967d9c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, sri@us.ibm.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100208132243.ab967d9c.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 8 Feb 2010 13:22:43 +1100

> After merging the net tree, today's linux-next build (powerpc
> ppc64_defconfig) failed like this:
 ...
> Caused by commit bfd5f4a3d605e0f6054df0b59fe0907ff7e696d3 ("packet: Add
> GSO/csum offload support").  This build has CONFIG_PACKET_MMAP unset.
> 
> I used the version of the net tree from next-20100205 for today.

Known problem, I'm fixing it by killing the config option,
everyone should have that thing enabled by now.
