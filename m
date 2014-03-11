From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 0/4 (v4)] stmmac fixes: EEE and chained mode
Date: Tue, 11 Mar 2014 16:16:06 -0400 (EDT)
Message-ID: <20140311.161606.493536375947957857.davem@davemloft.net>
References: <1394455234-32021-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755516AbaCKUQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 16:16:07 -0400
In-Reply-To: <1394455234-32021-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Mon, 10 Mar 2014 13:40:30 +0100

> These patches are to fix some new problems in the STMMAC driver.
> 
> Mandatory changes are for EEE that needs to be disabled if not supported
> and for the chain mode that is broken and the kernel panics if this mode
> is enabled.
> 
> v3: removed a patch from my previous set that touched the stmmac_tx path
>     that has not to be applied. Other patches for cleaning-up will be
>     sent on top of net-next git repo.
> 
> v4: do not surround the defaul buffer selection using Koption and adopt
>     a default to 1536bytes.

Series applied.
