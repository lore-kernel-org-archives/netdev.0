From: Afzal Mohammed <afzal.mohd.ma@gmail.com>
Subject: Re: [PATCH] net: ethernet: ti: cpdma: switch to use genalloc
Date: Fri, 24 Jun 2016 17:27:50 +0530
Message-ID: <20160624115750.GA5749@afzalpc>
References: <20160623123620.11681-1-grygorii.strashko@ti.com>
 <576BDC64.3030908@linaro.org>
 <576CCD9B.2050700@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
	linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <576CCD9B.2050700@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Fri, Jun 24, 2016 at 11:35:15AM +0530, Mugunthan V N wrote:
> On Thursday 23 June 2016 06:26 PM, Ivan Khoronzhuk wrote:

> >> +    if (pool->cpumap) {
> >> +        dma_free_coherent(pool->dev, pool->mem_size, pool->cpumap,
> >> +                  pool->phys);
> >> +    } else {
> >> +        iounmap(pool->iomap);
> >> +    }

> > single if, brackets?
> 
> if() has multiple line statement, so brackets are must.

Another paint to the bikeshed,

seems documented coding style mentions otherwise.

Regards
afzal
