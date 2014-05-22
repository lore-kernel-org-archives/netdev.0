From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: Remove unbalanced clk_disable call
Date: Thu, 22 May 2014 15:11:39 -0400 (EDT)
Message-ID: <20140522.151139.1356269536481386201.davem@davemloft.net>
References: <1400578698-6407-1-git-send-email-hdegoede@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, wens@csie.org, netdev@vger.kernel.org
To: hdegoede@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41537 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751288AbaEVTLl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 15:11:41 -0400
In-Reply-To: <1400578698-6407-1-git-send-email-hdegoede@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans de Goede <hdegoede@redhat.com>
Date: Tue, 20 May 2014 11:38:18 +0200

> The stmmac_open call was calling clk_disable_unprepare on phy init
> failure, but it never calls clk_prepare_enable, this causes
> a WARN_ON in the clk framework to trigger if for some reason phy init
> fails.
> 
> Signed-off-by: Hans de Goede <hdegoede@redhat.com>

Applied, thanks.
