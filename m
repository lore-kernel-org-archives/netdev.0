From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 8/9] net: ethernet: ti: cpts: fix overflow check period
Date: Wed, 14 Sep 2016 22:08:45 +0200
Message-ID: <20160914200845.GB12195@netboy>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
 <20160914130231.3035-9-grygorii.strashko@ti.com>
 <20160914142503.GF28592@localhost.localdomain>
 <d4cde14a-8147-6097-f034-c9cde6cdb718@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, WingMan Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <d4cde14a-8147-6097-f034-c9cde6cdb718@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 14, 2016 at 11:03:18PM +0300, Grygorii Strashko wrote:
> On 09/14/2016 05:25 PM, Richard Cochran wrote:
> > On Wed, Sep 14, 2016 at 04:02:30PM +0300, Grygorii Strashko wrote:
> >> @@ -427,9 +427,6 @@ static void cpts_calc_mult_shift(struct cpts *cpts)
> >>  	u64 ns;
> >>  	u64 frac;
> >>  
> >> -	if (cpts->cc_mult || cpts->cc.shift)
> >> -		return;
> >> -
> >>  	freq = clk_get_rate(cpts->refclk);
> >>  
> >>  	/* Calc the maximum number of seconds which we can run before
> > 
> > This hunk has nothing to do with $subject.
> 
> Sry, but I did not get your comment here :(
> I'd happy to update patch according to your request, but could you provide more info here, pls?

You added that code in patch #7.  Then you moved it in patch #8.  You
could have made the code correct in patch #7 to begin with.

> >>  	cpts->cc_mult = mult;
> >>  	cpts->cc.mult = mult;
> >>  	cpts->cc.shift = shift;
> >> +

If you want a blank line here, then put into the original patch #7.

Thanks,
Richard
