From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] stmmac: fix_mac_speed is called during
 10/100<->1000 speed changes
Date: Wed, 25 Aug 2010 16:30:59 -0700 (PDT)
Message-ID: <20100825.163059.245412297.davem@davemloft.net>
References: <1282632042-752-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pawel.moll@st.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40387
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751181Ab0HYXao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 19:30:44 -0400
In-Reply-To: <1282632042-752-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 24 Aug 2010 08:40:40 +0200

> From: Pawel Moll <pawel.moll@st.com>
> 
> This patch modifies the stmmac_adjust_link() function so the
> fix_mac_speed() is called not only when link speed is changing
> between 10 and 100 Mbps (as required in RMII mode) but also
> for 1000 Mbps.
> 
> Signed-off-by: Pawel Moll <pawel.moll@st.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
