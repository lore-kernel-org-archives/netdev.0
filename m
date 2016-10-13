From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 1/2] stmmac: fix ptp init for gmac4
Date: Thu, 13 Oct 2016 11:01:15 -0400 (EDT)
Message-ID: <20161013.110115.798187178234638035.davem@davemloft.net>
References: <1476279724-11817-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        alexandre.torgue@st.com, rayagond@vayavyalabs.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33812 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752909AbcJMPBy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 11:01:54 -0400
In-Reply-To: <1476279724-11817-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Wed, 12 Oct 2016 15:42:03 +0200

> The gmac 4.x version has not extended descriptors
> (that are available on 3.x instead of).
> While initializing the PTP module, the advanced PTP was
> enabled in case of extended descriptors. This cannot be
> applied for 4.x version where only the hardware capability
> register has to show if the feature is present.
> Patch also adds some extra netdev_(debug/inof) to better
> dump the configuration.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
