From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [2.6 patch] e1000e/ethtool.c: make a function
	static
Date: Wed, 30 Jan 2008 13:51:45 -0800
Message-ID: <47A0F171.6030106@intel.com>
References: <20080130200243.GY29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, Joe Perches <joe@perches.com>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080130200243.GY29368@does.not.exist>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> This patch makes the needlessly global reg_pattern_test_array() static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

stephen hemminger already pointed this out to me... I'll certainly push this
upstream, thanks Adrian!

Auke


> 
> ---
> ed72e457f06311390d9a9e51a00c904939466aff 
> diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
> index 6d9c27f..a2034cf 100644
> --- a/drivers/net/e1000e/ethtool.c
> +++ b/drivers/net/e1000e/ethtool.c
> @@ -690,8 +690,8 @@ err_setup:
>  	return err;
>  }
>  
> -bool reg_pattern_test_array(struct e1000_adapter *adapter, u64 *data,
> -			    int reg, int offset, u32 mask, u32 write)
> +static bool reg_pattern_test_array(struct e1000_adapter *adapter, u64 *data,
> +				   int reg, int offset, u32 mask, u32 write)
>  {
>  	int i;
>  	u32 read;
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
