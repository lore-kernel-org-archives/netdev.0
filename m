From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH net-next] powerpc: use asm-generic/socket.h as much as possible
Date: Wed, 31 May 2017 20:15:55 +1000
Message-ID: <878tld49ic.fsf@concordia.ellerman.id.au>
References: <20170531154337.04ebcb75@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        PowerPC <linuxppc-dev@lists.ozlabs.org>,
        Arnd Bergmann <arnd@arndb.de>
To: Stephen Rothwell <sfr@canb.auug.org.au>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:38187 "EHLO ozlabs.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750912AbdEaKP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 06:15:59 -0400
In-Reply-To: <20170531154337.04ebcb75@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Rothwell <sfr@canb.auug.org.au> writes:

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

Did you boot it and test that userspace was happy doing sockety things?

cheers
