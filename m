From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH] net: ethernet: ti: cpdma: remove used_desc counter
Date: Tue, 9 Aug 2016 13:56:15 +0530
Message-ID: <d6ed364c-d4e4-db7a-545b-dd74b3c1c1ab@ti.com>
References: <20160804152051.30565-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160804152051.30565-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 04 August 2016 08:50 PM, Grygorii Strashko wrote:
> The struct cpdma_desc_pool->used_desc field can be safely removed from
> CPDMA driver (and hot patch) because used_descs counter is used just
> for pool consistency check at CPDMA deinitialization and now this
> check can be re-implemnted using gen_pool_size(pool->gen_pool) !=
> gen_pool_avail(pool->gen_pool).
> More over, this will allow to get rid of warnings in
> cpdma_desc_pool_destro()-> WARN_ON(pool->used_desc) which may happen
> because the used_descs is used unprotected, since CPDMA has been
> switched to use genalloc, and may get wrong values on SMP.
> 
> Hence, remove used_desc from struct cpdma_desc_pool.
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>

Regards
Mugunthan V N
