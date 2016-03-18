From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: stmmac: Don't search for phys if mdio node is
 defined.
Date: Fri, 18 Mar 2016 18:31:24 -0400 (EDT)
Message-ID: <20160318.183124.2299925497256914953.davem@davemloft.net>
References: <1458027273-127737-1-git-send-email-preid@electromag.com.au>
	<1458027273-127737-2-git-send-email-preid@electromag.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: preid@electromag.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbcCRWb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 18:31:27 -0400
In-Reply-To: <1458027273-127737-2-git-send-email-preid@electromag.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Reid <preid@electromag.com.au>
Date: Tue, 15 Mar 2016 15:34:33 +0800

> If a dt mdio entry has been added least assume that we wont
> search for phys attached. The DT and of_mdiobus_register already do
> this. This stops DSA phys being found and phys created for them, as
> this is handled by the DSA driver.
> 
> Signed-off-by: Phil Reid <preid@electromag.com.au>

Applied.
