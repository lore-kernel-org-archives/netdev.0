From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/5] net-next: stmmac: rework the speed selection
Date: Thu, 25 May 2017 13:08:53 -0400 (EDT)
Message-ID: <20170525.130853.606472240884291471.davem@davemloft.net>
References: <20170524071647.7921-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170524071647.7921-1-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Wed, 24 May 2017 09:16:42 +0200

> The current stmmac_adjust_link() part which handle speed have
> some if (has_platform) code and my dwmac-sun8i will add more of them.
> 
> So we need to handle better speed selection.
> Moreover the struct link member speed and port are hard to guess their
> purpose. And their unique usage are to be combined for writing speed.
> 
> My first try was to create an adjust_link() in stmmac_ops but it duplicate some code
> 
> The current solution is to have direct value for 10/100/1000 and a mask for them.
> 
> The first 4 patchs fix some minor problem found in stmmac_adjust_link() and reported by Florian Fainelli in my previous serie.
> The last patch is the real work.
> 
> This series is tested on cubieboard2 (dwmac1000) and opipc (dwmac-sun8i).

Series applied.
