From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Subject: Re: [PATCH] net: ethernet: ti: cpdma: switch to use genalloc
Date: Fri, 24 Jun 2016 12:15:41 -0400
Message-ID: <20160624161541.GA23499@csclub.uwaterloo.ca>
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

On Fri, Jun 24, 2016 at 11:35:15AM +0530, Mugunthan V N wrote:
> >> +static void cpdma_desc_pool_destroy(struct cpdma_desc_pool *pool)
> >> +{
> >> +    if (!pool)
> >> +        return;
> >> +
> >> +    WARN_ON(pool->used_desc);
> >> +    if (pool->cpumap) {
> >> +        dma_free_coherent(pool->dev, pool->mem_size, pool->cpumap,
> >> +                  pool->phys);
> >> +    } else {
> >> +        iounmap(pool->iomap);
> >> +    }
> >> +}
> >> +
> > single if, brackets?
> 
> if() has multiple line statement, so brackets are must.

It is line wrapped, it is still one statement.  And you can't argue the
else being multiple lines, although the style does require using brackets
for the else if the if required them.

Style says "Do not unnecessarily use braces where a single statement will do."
It says statement, not line.  A multiline wrapped statement is still
one statement.

I may personally hate the lack of brackets, but style wise it seems very
clear that the linux kernel only uses brakcets when required, which is
only when there is more than one statement.  I prefer what you did,
but not as much as I prefer consistency.

-- 
Len Sorensen
