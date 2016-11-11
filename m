From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [mm PATCH v3 12/23] arch/nios2: Add option to skip DMA sync as a
 part of map and unmap
Date: Fri, 11 Nov 2016 11:58:19 +0100
Message-ID: <20161111105818.GB9338@distanz.ch>
References: <20161110113027.76501.63030.stgit@ahduyck-blue-test.jf.intel.com>
 <20161110113518.76501.52225.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mm@kvack.org, akpm@linux-foundation.org,
        Ley Foon Tan <lftan@altera.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161110113518.76501.52225.stgit@ahduyck-blue-test.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016-11-10 at 12:35:18 +0100, Alexander Duyck <alexander.h.duyck@intel.com> wrote:
> This change allows us to pass DMA_ATTR_SKIP_CPU_SYNC which allows us to
> avoid invoking cache line invalidation if the driver will just handle it
> via a sync_for_cpu or sync_for_device call.
> 
> Cc: Ley Foon Tan <lftan@altera.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Reviewed-by: Tobias Klauser <tklauser@distanz.ch>
