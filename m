From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git)] net: phy: rtl8211: fix interrupt on status
 link change
Date: Tue, 20 Aug 2013 17:11:25 -0700 (PDT)
Message-ID: <20130820.171125.1485746995632268420.davem@davemloft.net>
References: <A1A6EA40F8503D48BB002B42BD65974E0A0E6C8C@039-SN2MPN1-012.039d.mgd.msft.net>
	<1376894914-11174-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49124 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524Ab3HUAL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Aug 2013 20:11:26 -0400
In-Reply-To: <1376894914-11174-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Mon, 19 Aug 2013 08:48:34 +0200

> This is to fix a problem in the rtl8211 where the driver
> wasn't properly enabled the interrupt on link change status.
> it has to enable the ineterrupt on the bit 10 in the register 18
> (INER).
> 
> Reported-by: Sharma Bhupesh <B45370@freescale.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied, thanks.
