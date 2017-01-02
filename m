From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH net 0/3] net: stmmac: dwmac-oxnas: fix leaks and simplify
 pm
Date: Mon, 2 Jan 2017 16:03:45 +0100
Message-ID: <438b7c44-cf88-823f-80cf-3d017d85cbf2@baylibre.com>
References: <20170102115604.32482-1-johan@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org, linux-oxnas@lists.tuxfamily.org,
        linux-kernel@vger.kernel.org
To: Johan Hovold <johan@kernel.org>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170102115604.32482-1-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/02/2017 12:56 PM, Johan Hovold wrote:
> These patches fixes of-node and fixed-phydev leaks in the recently added
> dwmac-oxnas driver, and ultimately switches over to using the generic pm
> implementation as the required callbacks are now in place.
> 
> Note that this series has only been compile tested.
> 
> Johan
> 
> 
> Johan Hovold (3):
>   net: stmmac: dwmac-oxnas: fix of-node leak
>   net: stmmac: dwmac-oxnas: fix fixed-link-phydev leaks
>   net: stmmac: dwmac-oxnas: use generic pm implementation
> 
>  drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c | 89 +++++++++--------------
>  1 file changed, 33 insertions(+), 56 deletions(-)
> 

Hi Johan,

This series looks good, I will (hopefully) send a Tested-by in the next few days.

Thanks,
Neil
