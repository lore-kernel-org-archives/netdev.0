From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH (net.git) 1/2] stmmac: fix the rx csum feature
Date: Mon, 01 Sep 2014 21:52:11 -0700 (PDT)
Message-ID: <20140901.215211.827936218516063252.davem@davemloft.net>
References: <1409555873-5478-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47434 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbaIBEwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 00:52:12 -0400
In-Reply-To: <1409555873-5478-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Date: Mon, 1 Sep 2014 09:17:52 +0200

> For new GMACs it is possible to turn-on/off the COE.
> In the current driver, when disabled the Rx-checksum
> via ethtool, the tool reported that csum was disabled
> but the HW continued to set the IPC. Indeed this is
> because the fix_features allows this. So the patch
> fixes this problem by adding the set_features.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
