From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Wed, 17 Mar 2010 23:23:00 -0700 (PDT)
Message-ID: <20100317.232300.39195654.davem@davemloft.net>
References: <20100318152351.df9e11a3.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, therbert@google.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100318152351.df9e11a3.sfr@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 18 Mar 2010 15:23:51 +1100

> After merging the final tree, today's linux-next build (powerpc
> ppc44x_defconfig) failed like this:
> 
> net/core/dev.c: In function 'net_rps_action':
> net/core/dev.c:3183: error: implicit declaration of function '__smp_call_function_single'
> 
> Caused by commit 0a9627f2649a02bea165cfd529d7bcb625c2fcad ("rps: Receive
> Packet Steering") from the net tree.   This config does not have
> CONFIG_SMP set.  __smp_call_function_single is only available when
> CONFIG_SMP is set.

Tom, please send me a fix for this soon.

Thanks!
