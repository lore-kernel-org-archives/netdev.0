From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net-next.git) 09/18] stmmac: optimize tx desc
 management
Date: Mon, 04 Jan 2016 22:39:16 -0500 (EST)
Message-ID: <20160104.223916.1424025684080316788.davem@davemloft.net>
References: <1451912823-5245-1-git-send-email-peppe.cavallaro@st.com>
	<1451912823-5245-10-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexandre.torgue@st.com,
	fabrice.gasnier@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbcAEDjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 22:39:18 -0500
In-Reply-To: <1451912823-5245-10-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Mon, 4 Jan 2016 14:06:54 +0100

> @@ -334,12 +334,11 @@ struct stmmac_desc_ops {
>  
>  	/* Invoked by the xmit function to prepare the tx descriptor */
>  	void (*prepare_tx_desc) (struct dma_desc *p, int is_fs, int len,
> -				 int csum_flag, int mode);
> +				 int csum_flag, int mode, int tx_own,
> +				 bool ls_ic);

I don't understand how you can get the type right and use 'bool' for
'ls_ic' but then incorrectly use an int for 'tx_own'.
