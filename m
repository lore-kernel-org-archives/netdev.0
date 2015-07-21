From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] stmmac: fix setting of driver data in
 stmmac_dvr_probe
Date: Tue, 21 Jul 2015 00:26:58 -0700 (PDT)
Message-ID: <20150721.002658.2006139267633280639.davem@davemloft.net>
References: <1437169697-20388-1-git-send-email-manabian@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org
To: manabian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbbGUH07 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 03:26:59 -0400
In-Reply-To: <1437169697-20388-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joachim Eastwood <manabian@gmail.com>
Date: Fri, 17 Jul 2015 23:48:17 +0200

> Commit 803f8fc46274b ("stmmac: move driver data setting into
> stmmac_dvr_probe") mistakenly set priv and not priv->dev as
> driver data. This meant that the remove, resume and suspend
> callbacks that fetched and tried to use this data would most
> likely explode. Fix the issue by using the correct variable.
> 
> Fixes: 803f8fc46274b ("stmmac: move driver data setting into stmmac_dvr_probe")
> Signed-off-by: Joachim Eastwood <manabian@gmail.com>

Applied, thanks.
