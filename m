From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [RFC: 2.6 patch] #if 0 e1000e_read_nvm_spi()
Date: Mon, 03 Mar 2008 09:24:35 -0800
Message-ID: <47CC3453.9010108@intel.com>
References: <20080301162302.GX25835@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080301162302.GX25835@cs181133002.pp.htv.fi>
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
> This patch #if 0's the no longer used e1000e_read_nvm_spi().

OK, thanks Adrian

I'll send a patch to remove the function alltogether.

Auke


> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
>  drivers/net/e1000e/e1000.h |    1 -
>  drivers/net/e1000e/lib.c   |    2 ++
>  2 files changed, 2 insertions(+), 1 deletion(-)
> 
> 9bab4dc421a7e5a947739e2fa1363b4efffbcbe2 foobar
> diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
> index 327c062..6e0c6ed 100644
> --- a/drivers/net/e1000e/e1000.h
> +++ b/drivers/net/e1000e/e1000.h
> @@ -462,7 +462,6 @@ extern s32 e1000e_acquire_nvm(struct e1000_hw *hw);
>  extern s32 e1000e_write_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
>  extern s32 e1000e_update_nvm_checksum_generic(struct e1000_hw *hw);
>  extern s32 e1000e_poll_eerd_eewr_done(struct e1000_hw *hw, int ee_reg);
> -extern s32 e1000e_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
>  extern s32 e1000e_read_nvm_eerd(struct e1000_hw *hw, u16 offset, u16 words, u16 *data);
>  extern s32 e1000e_validate_nvm_checksum_generic(struct e1000_hw *hw);
>  extern void e1000e_release_nvm(struct e1000_hw *hw);
> diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
> index 95f75a4..cb2dac8 100644
> --- a/drivers/net/e1000e/lib.c
> +++ b/drivers/net/e1000e/lib.c
> @@ -1851,6 +1851,7 @@ static s32 e1000_ready_nvm_eeprom(struct e1000_hw *hw)
>  	return 0;
>  }
>  
> +#if 0
>  /**
>   *  e1000e_read_nvm_spi - Reads EEPROM using SPI
>   *  @hw: pointer to the HW structure
> @@ -1906,6 +1907,7 @@ s32 e1000e_read_nvm_spi(struct e1000_hw *hw, u16 offset, u16 words, u16 *data)
>  	nvm->ops.release_nvm(hw);
>  	return 0;
>  }
> +#endif  /*  0  */
>  
>  /**
>   *  e1000e_read_nvm_eerd - Reads EEPROM using EERD register
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
