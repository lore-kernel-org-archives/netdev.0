From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] drivers:net: Convert
 dma_alloc_coherent(...__GFP_ZERO) to dma_zalloc_coherent
Date: Tue, 27 Aug 2013 09:07:47 -0400
Message-ID: <20130827130747.GA7619@hmsreliant.think-freely.org>
References: <dbbfc5e66dba7d2b63549d218407fb0c4031f2ed.1363367992.git.joe@perches.com>
 <1377582323.2658.10.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	users@rt2x00.serialmonkey.com, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, b43-dev@lists.infradead.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1377582323.2658.10.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 26, 2013 at 10:45:23PM -0700, Joe Perches wrote:
> __GFP_ZERO is an uncommon flag and perhaps is better
> not used.  static inline dma_zalloc_coherent exists
> so convert the uses of dma_alloc_coherent with __GFP_ZERO
> to the more common kernel style with zalloc.
> 
> Remove memset from the static inline dma_zalloc_coherent
> and add just one use of __GFP_ZERO instead.
> 
> Trivially reduces the size of the existing uses of
> dma_zalloc_coherent.
> 
> Realign arguments as appropriate.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
