From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 11/27] drivers/net/igb: remove dead code (function 'igb_read_pci_cfg')
Date: Mon, 22 Dec 2008 14:30:00 -0800
Message-ID: <9929d2390812221430j1bc15607m58dd07a6ac8dec5@mail.gmail.com>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	 <20081222191632.11807.3776.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Hannes Eder" <hannes@hanneseder.net>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:50058 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755825AbYLVWaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 17:30:01 -0500
In-Reply-To: <20081222191632.11807.3776.stgit@vmbox.hanneseder.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2008 at 11:16 AM, Hannes Eder <hannes@hanneseder.net> wrote:
> Fix this warning:
>
>  drivers/net/igb/e1000_mac.c:54: warning: 'igb_read_pci_cfg' defined but not used
>
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> ---
>  drivers/net/igb/e1000_mac.c |    7 -------
>  1 files changed, 0 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
> index 137269d..97f0049 100644
> --- a/drivers/net/igb/e1000_mac.c
> +++ b/drivers/net/igb/e1000_mac.c
> @@ -50,13 +50,6 @@ void igb_remove_device(struct e1000_hw *hw)
>        kfree(hw->dev_spec);
>  }
>
> -static void igb_read_pci_cfg(struct e1000_hw *hw, u32 reg, u16 *value)
> -{
> -       struct igb_adapter *adapter = hw->back;
> -
> -       pci_read_config_word(adapter->pdev, reg, value);
> -}
> -
>  static s32 igb_read_pcie_cap_reg(struct e1000_hw *hw, u32 reg, u16 *value)
>  {
>        struct igb_adapter *adapter = hw->back;
>


Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Sorry, I caught this earlier and meant to have patch pushed out last
week.  Thanks for correcting this.

-- 
Cheers,
Jeff
