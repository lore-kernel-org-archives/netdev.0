From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git 0/3 (v2)] stmmac: review driver Koptions
Date: Wed, 05 Nov 2014 16:15:33 -0500 (EST)
Message-ID: <20141105.161533.301569812388792280.davem@davemloft.net>
References: <1415112574-21321-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48244 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751302AbaKEVPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 16:15:37 -0500
In-Reply-To: <1415112574-21321-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Tue, 4 Nov 2014 15:49:31 +0100

> Recently many Koption options have been added to have new glue logic on several
> platforms.
> 
> The main goal behind this work is to guarantee that the driver built 
> fine on all the branches where it is present independently of which
> glue logic is selected.
> 
> IMHO, it is better to remove all the not necessary Koption(s) that can hide 
> build problems when something changes in the driver and especially when 
> the DT compatibility allows us to manage all the platform data.
> 
> I compiled the driver w/o any issue on net-next Git for:
> 
>   x86, arm and sh4.
> 
> In case of there are build problems on some repos now it will be
> easy to catch them and cherry-pick patches from mainstream.
> 
> For sure, do not hesitate to contact me in case of issue.
> 
> Also this set removes STMMAC_DEBUG_FS and BUS_MODE_DA. The latter is useless
> and the former can be replaced by DEBUG_FS (always to make safe the build).
> 
> V2: patch-set re-based on top of the latest updates for net-next

Series applied, thanks.
