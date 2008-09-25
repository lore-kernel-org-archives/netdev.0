From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 16/21] atl1e: remove the unneeded (struct atl1e_adapter
 *)
Date: Wed, 24 Sep 2008 20:49:52 -0400
Message-ID: <48DAE030.5050003@garzik.org>
References: <200809222152.m8MLqPYL031984@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jie.yang@atheros.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47013 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752000AbYIYAt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 20:49:57 -0400
In-Reply-To: <200809222152.m8MLqPYL031984@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Jie Yang <jie.yang@atheros.com>
> 
> Remove the unneeded (struct atl1e_adapter *) casts, for hw->adapter
> already has type atl1e_adapter *.
> 
> Signed-off-by: Jie Yang <jie.yang@atheros.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/atl1e/atl1e_hw.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff -puN drivers/net/atl1e/atl1e_hw.c~atl1e-remove-the-unneeded-struct-atl1e_adapter drivers/net/atl1e/atl1e_hw.c
> --- a/drivers/net/atl1e/atl1e_hw.c~atl1e-remove-the-unneeded-struct-atl1e_adapter
> +++ a/drivers/net/atl1e/atl1e_hw.c
> @@ -397,7 +397,7 @@ static int atl1e_phy_setup_autoneg_adv(s
>   */
>  int atl1e_phy_commit(struct atl1e_hw *hw)
>  {
> -	struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
> +	struct atl1e_adapter *adapter = hw->adapter;
>  	struct pci_dev *pdev = adapter->pdev;
>  	int ret_val;
>  	u16 phy_data;
> @@ -431,7 +431,7 @@ int atl1e_phy_commit(struct atl1e_hw *hw
>  
>  int atl1e_phy_init(struct atl1e_hw *hw)
>  {
> -	struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
> +	struct atl1e_adapter *adapter = hw->adapter;
>  	struct pci_dev *pdev = adapter->pdev;
>  	s32 ret_val;
>  	u16 phy_val;
> @@ -525,7 +525,7 @@ int atl1e_phy_init(struct atl1e_hw *hw)
>   */
>  int atl1e_reset_hw(struct atl1e_hw *hw)
>  {
> -	struct atl1e_adapter *adapter = (struct atl1e_adapter *)hw->adapter;
> +	struct atl1e_adapter *adapter = hw->adapter;
>  	struct pci_dev *pdev = adapter->pdev;
>  
>  	u32 idle_status_data = 0;

applied


