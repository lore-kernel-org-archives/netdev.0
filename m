From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: Re: [PATCH 1/2] net-next: stmmac: add adjust_link function
Date: Wed, 17 May 2017 10:21:29 +0200
Message-ID: <20170517082129.GB19202@Red>
References: <20170515114140.1676-1-clabbe.montjoie@gmail.com>
 <b54c0535-f3b2-6184-1422-ec9eed22e67f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <b54c0535-f3b2-6184-1422-ec9eed22e67f@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2017 at 09:43:04AM -0700, Florian Fainelli wrote:
> On 05/15/2017 04:41 AM, Corentin Labbe wrote:
> > My dwmac-sun8i serie will add some if (has_sun8i) to
> > stmmac_adjust_link()
> > Since the current stmmac_adjust_link() alreaady have lots of if (has_gmac/gmac4),
> > It is now better to create an adjust_link() function for each dwmac.
> 
> Is it really, because the diffstat really seems to indicate otherwise
> and by looking at the code, I am definitively not convinced this is an
> improvement other the current code.
> 
> > 
> > So this patch add an adjust_link() function pointer, and move code out
> > of stmmac_adjust_link to it.
> 
> Can't we keep the existing adjust_link() function and just have a
> different one for dwmac-sun8i that either re-uses portions of the
> existing, or duplicate just what it needs?
> 

I found another way, removing port/speed variable and use new struct links member speed10/speed100/speed1000/speedmask 
I will make the current adjust_link function simplier. (and no if has_xxx for any dwmac type)

I will send that try soon.
