From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 3/4] sh_eth: Remove obsolete r8a7740-gether
 platform_device_id entry
Date: Thu, 8 Oct 2015 11:07:49 +0900
Message-ID: <20151008020748.GB8756@verge.net.au>
References: <1444205657-25314-1-git-send-email-geert+renesas@glider.be>
 <1444205657-25314-4-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1444205657-25314-4-git-send-email-geert+renesas@glider.be>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 07, 2015 at 10:14:16AM +0200, Geert Uytterhoeven wrote:
> Since commit 1fa59bda21c7fa36 ("ARM: shmobile: Remove legacy board code
> for Armadillo-800 EVA"), r8a7740 is only supported in generic DT-only
> ARM multi-platform builds.  The driver doesn't need to match platform
> devices by name anymore, hence remove the corresponding
> platform_device_id entry.
> 
> Protect r8a7740_data by #ifdef CONFIG_OF as it's now referenced on DT
> platforms only. Move it to a more logical position, in front of the
> r8a777x support, so we can have a single #ifdef covering all r7s* and
> r8a* support soon. This requires moving a few helper functions, too.
> 
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Acked-by: Simon Horman <horms+renesas@verge.net.au>

