From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: hardware TX COE doesn't work when
 force_thresh_dma_mode is set
Date: Mon, 16 May 2016 22:18:08 -0400 (EDT)
Message-ID: <20160516.221808.254390666322980371.davem@davemloft.net>
References: <1463413267-19543-1-git-send-email-ezequiel@vanguardiasur.com.ar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, manabian@gmail.com
To: ezequiel@vanguardiasur.com.ar
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41326 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754809AbcEQCSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 22:18:11 -0400
In-Reply-To: <1463413267-19543-1-git-send-email-ezequiel@vanguardiasur.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>
Date: Mon, 16 May 2016 12:41:07 -0300

> Commit f748be531d70 ("stmmac: support new GMAC4") reverted a previous fix
> by mistake. This commit re-applies said fix:
> 
>   commit dec2165ff38a99f937fe61875d102c6c8596c815
>   Author: Sonic Zhang <sonic.zhang@analog.com>
>   Date:   Thu Jan 22 14:55:57 2015 +0800
>   stmmac: hardware TX COE doesn't work when force_thresh_dma_mode is set
> 
>   Clear the TX COE bit when force_thresh_dma_mode is set even hardware
>   dma capability says support.
> 
>   Tested on BF609.
> 
>   Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>   Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>   Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Tested on LPC4350 Hitex board.
> 
> Fixes: f748be531d70 ("stmmac: support new GMAC4")
> Signed-off-by: Ezequiel Garcia <ezequiel@vanguardiasur.com.ar>

Applied.
