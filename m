From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] powerpc: use asm-generic/socket.h as much as
 possible
Date: Thu, 01 Jun 2017 14:48:24 -0400 (EDT)
Message-ID: <20170601.144824.1502450180029174361.davem@davemloft.net>
References: <20170531154337.04ebcb75@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mpe@ellerman.id.au,
        benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org,
        arnd@arndb.de
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58416 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751435AbdFASs0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 14:48:26 -0400
In-Reply-To: <20170531154337.04ebcb75@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 31 May 2017 15:43:37 +1000

> asm-generic/socket.h already has an exception for the differences that
> powerpc needs, so just include it after defining the differences.
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  arch/powerpc/include/uapi/asm/socket.h | 92 +---------------------------------
>  1 file changed, 1 insertion(+), 91 deletions(-)
> 
> Build tested using powerpc allyesconfig, pseries_le_defconfig, 32 bit
> and 64 bit allnoconfig and ppc44x_defconfig builds.
> 
> Dave, this is on top of the net-next tree and I am sending it to you
> since it would produce a conflict if it was merged via the powerpc tree.

Ok, I applied this to net-next, thanks Stephen!
