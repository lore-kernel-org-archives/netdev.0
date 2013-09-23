From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question tehuti.c
Date: Mon, 23 Sep 2013 17:54:00 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1309231752040.2242@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: andy@greyhouse.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function bdx_setmulti in the file drivers/net/ethernet/tehuti/tehuti.c
contains:

        u32 rxf_val =
            GMAC_RX_FILTER_AM | GMAC_RX_FILTER_AB | GMAC_RX_FILTER_OSEN;

and then later:

       } else {
                DBG("only own mac %d\n", netdev_mc_count(ndev));
                rxf_val |= GMAC_RX_FILTER_AB;
        }

The last assignment doesn't look very useful, because GMAC_RX_FILTER_ABis
already included in rxf_val.  Was something else intended?

thanks,
julia
