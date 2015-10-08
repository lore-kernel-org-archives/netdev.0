From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 4/4] sh_eth: Remove obsolete r8a777x-ether
 platform_device_id entry
Date: Thu, 8 Oct 2015 11:07:34 +0900
Message-ID: <20151008020731.GA8756@verge.net.au>
References: <1444205657-25314-1-git-send-email-geert+renesas@glider.be>
 <1444205657-25314-5-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444205657-25314-5-git-send-email-geert+renesas@glider.be>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 07, 2015 at 10:14:17AM +0200, Geert Uytterhoeven wrote:
> Since commit 3d7608e4c169af03 ("ARM: shmobile: bockw: remove legacy
> board file and config"), R-Car Gen1 SoCs are only supported in generic
> DT-only ARM multi-platform builds.  The driver doesn't need to match
> platform devices by name anymore, hence remove the corresponding
> platform_device_id entry.
> 
> Protect sh_eth_set_rate_r8a777x() and r8a777x_data by #ifdef CONFIG_OF,
> as they're now referenced on DT platforms only.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Acked-by: Simon Horman <horms+renesas@verge.net.au>
