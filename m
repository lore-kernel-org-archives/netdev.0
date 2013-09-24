From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: question tehuti.c
Date: Tue, 24 Sep 2013 11:34:32 -0400
Message-ID: <20130924153432.GI9773@gospo.rdu.redhat.com>
References: <alpine.DEB.2.02.1309231752040.2242@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexander Indenbaum <baum@tehutinetworks.net>
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1309231752040.2242@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 23, 2013 at 05:54:00PM +0200, Julia Lawall wrote:
> The function bdx_setmulti in the file drivers/net/ethernet/tehuti/tehuti.c
> contains:
> 
>         u32 rxf_val =
>             GMAC_RX_FILTER_AM | GMAC_RX_FILTER_AB | GMAC_RX_FILTER_OSEN;
> 
> and then later:
> 
>        } else {
>                 DBG("only own mac %d\n", netdev_mc_count(ndev));
>                 rxf_val |= GMAC_RX_FILTER_AB;
>         }
> 
> The last assignment doesn't look very useful, because GMAC_RX_FILTER_ABis
> already included in rxf_val.  Was something else intended?

You are correct that the setting of GMAC_RX_FILTER_AB is a bit redundant
since it was set earlier in the function.

I have not worked on this driver in several years and if there is no
response from Alexander or someone else at Tehuti Networks then you may
not get an answer to your question. :-/
