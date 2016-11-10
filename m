From: Richard Kuo <rkuo@codeaurora.org>
Subject: Re: [mm PATCH v3 07/23] arch/hexagon: Add option to skip DMA sync as
 a part of mapping
Date: Thu, 10 Nov 2016 12:40:14 -0600
Message-ID: <20161110184014.GA30680@codeaurora.org>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
 <20161110113452.76501.45864.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, akpm@linux-foundation.org,
        linux-hexagon@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161110113452.76501.45864.stgit@ahduyck-blue-test.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 10, 2016 at 06:34:52AM -0500, Alexander Duyck wrote:
> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
> avoid invoking cache line invalidation if the driver will just handle it
> later via a sync_for_cpu or sync_for_device call.
> 
> Cc: Richard Kuo <rkuo@codeaurora.org>
> Cc: linux-hexagon@vger.kernel.org
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  arch/hexagon/kernel/dma.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 

For Hexagon:

Acked-by: Richard Kuo <rkuo@codeaurora.org>



-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum, 
a Linux Foundation Collaborative Project
