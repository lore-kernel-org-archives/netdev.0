From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.3.0] phy:icplus:fix Auto Power Saving in
 ip101a_config_init.
Date: Tue, 03 Apr 2012 18:49:37 -0400 (EDT)
Message-ID: <20120403.184937.744089580257691570.davem@davemloft.net>
References: <1333360929-31506-1-git-send-email-srinivas.kandagatla@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: srinivas.kandagatla@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684Ab2DCWto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 18:49:44 -0400
In-Reply-To: <1333360929-31506-1-git-send-email-srinivas.kandagatla@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Date: Mon,  2 Apr 2012 11:02:09 +0100

> From: Srinivas Kandagatla <srinivas.kandagatla@st.com>
> 
> This patch fixes Auto Power Saving configuration in ip101a_config_init
> which was broken as there is no phy register write followed after
> setting IP101A_APS_ON flag.
> 
> This patch also fixes the return value of ip101a_config_init.
> 
> Without this patch ip101a_config_init returns 2 which is not an error
> accroding to IS_ERR and the mac driver will continue accessing 2 as
> valid pointer to phy_dev resulting in memory fault.
> 
> Signed-off-by: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Applied and queued up for -stable, thanks.
