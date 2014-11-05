From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 0/5] stmmac: review and fix lock and atomicity
Date: Wed, 05 Nov 2014 16:24:08 -0500 (EST)
Message-ID: <20141105.162408.776250626924229773.davem@davemloft.net>
References: <1415117289-7733-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbaKEVYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 16:24:12 -0500
In-Reply-To: <1415117289-7733-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Tue, 4 Nov 2014 17:08:04 +0100

> Recently some issues have been reported for the driver for locking mechanism
> and atomicity.
> 
> In fact, enabling DEBUG support to prove lock and to verify if sleeping while
> atomic context some warnings occur at runtime. I have reproduced all on STi
> platforms.
> 
> Concerning the tx path, I had provided a patch time ago but
> I discarded the idea to completely remove locks; in this patch-set we can have
> some useful fixes instead of.
> 
> This patch-set is to fix the atomicity in the PM stuff where I tried to collect
> all the points and advice reported in the past weeks.
> As final result, on my side no warnings and no problem when suspend/resume the
> driver on STi boxes.
> 
> I also added a patch that fixes the locks for the EEE.
> As pointed in some thread there was a design problem behind the eee
> initialization and I have tried to fix that before.
> As final result no issues when proving locks too.

Series applied, thanks.
