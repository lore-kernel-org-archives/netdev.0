From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 3/3] stmmac: fix automatic PAD/FCS stripping
Date: Tue, 27 Jul 2010 20:45:45 -0700 (PDT)
Message-ID: <20100727.204545.55874058.davem@davemloft.net>
References: <1280225387-26240-1-git-send-email-peppe.cavallaro@st.com>
	<1280225387-26240-2-git-send-email-peppe.cavallaro@st.com>
	<1280225387-26240-3-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48823
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753820Ab0G1Dp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 23:45:28 -0400
In-Reply-To: <1280225387-26240-3-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 27 Jul 2010 12:09:47 +0200

> For Simple Ethernet frames (802.2 and 802.3) the GMAC Core
> never strips pad and fcs. This means the ACS has no effect
> on IPv4/6 frames.
> The FL bits, in the RDES0, include the FCS so the driver
> has to remove it in SW.
> For 802.3 frame format with LLC or LLC-SNAP, when set the ACS
> bit, the HW strips both PAD and FCS.
> The FL bits, in the RDES0, actually represents the frame length
> already stripped.
> This patch fixes this logic within the device driver that
> erroneously removed 4byte from 802.3 frames already stripped
> corrupting the payload.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
