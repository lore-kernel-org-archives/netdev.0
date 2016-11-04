From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [mm PATCH v2 18/26] arch/powerpc: Add option to skip DMA sync as a part of mapping
Date: Fri, 04 Nov 2016 14:16:01 +1100
Message-ID: <87twbolytq.fsf@concordia.ellerman.id.au>
References: <20161102111031.79519.14741.stgit@ahduyck-blue-test.jf.intel.com> <20161102111513.79519.65315.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-kernel@vger.kernel.org, Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Alexander Duyck <alexander.h.duyck@intel.com>, linux-mm@kvack.org, akpm@linux-foundation.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20161102111513.79519.65315.stgit@ahduyck-blue-test.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Alexander Duyck <alexander.h.duyck@intel.com> writes:

> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
> avoid invoking cache line invalidation if the driver will just handle it
> via a sync_for_cpu or sync_for_device call.
>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: linuxppc-dev@lists.ozlabs.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  arch/powerpc/kernel/dma.c |    9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)

LGTM.

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
