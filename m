From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 2/6] net: ethernet: ti: cpts: add support for ext rftclk
 selection
Date: Mon, 5 Dec 2016 08:51:09 -0600
Message-ID: <20161205145109.ehzxzejpfhpwacle@rob-hp-laptop>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-3-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, devicetree@vger.kernel.org,
        Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161128230428.6872-3-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 28, 2016 at 05:04:24PM -0600, Grygorii Strashko wrote:
> Some CPTS instances, which can be found on KeyStone 2 1/10G Ethernet
> Switch Subsystems, can control an external multiplexer that selects
> one of up to 32 clocks for time sync reference (RFTCLK). This feature
> can be configured through CPTS_RFTCLK_SEL register (offset: x08).
> 
> Hence, introduce optional DT cpts_rftclk_sel poperty wich, if present,
> will specify CPTS reference clock. The cpts_rftclk_sel should be
> omitted in DT if HW doesn't support this feature. The external fixed
> rate clocks can be defined in board files as "fixed-clock".
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
> ---
>  Documentation/devicetree/bindings/net/keystone-netcp.txt |  2 ++

Please group binding changes into a single patch.

>  drivers/net/ethernet/ti/cpts.c                           | 12 ++++++++++++
>  drivers/net/ethernet/ti/cpts.h                           |  8 +++++++-
>  3 files changed, 21 insertions(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/keystone-netcp.txt b/Documentation/devicetree/bindings/net/keystone-netcp.txt
> index c37b54e..ec4a241 100644
> --- a/Documentation/devicetree/bindings/net/keystone-netcp.txt
> +++ b/Documentation/devicetree/bindings/net/keystone-netcp.txt
> @@ -114,6 +114,8 @@ Optional properties:
>  				driver to them if needed.
>  
>   Properties related to cpts configurations.
> +	- cpts-rftclk-sel: selects one of up to 32 clocks for time sync
> +		reference.  Default = 0.

Vendor prefix.

>  	- cpts_clock_mult/cpts_clock_shift:
>  		used for converting time counter cycles to ns as in
>  
