From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: SMSC device Energy Detect power-down mode
Date: Fri, 25 Dec 2009 18:38:29 -0800 (PST)
Message-ID: <20091225.183829.246551084.davem@davemloft.net>
References: <1260948498-28544-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47195
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756630AbZLZCi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Dec 2009 21:38:27 -0500
In-Reply-To: <1260948498-28544-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Wed, 16 Dec 2009 08:28:18 +0100

> SMSC Ethernet Transceivers (LAN88710, LAN8710, LAN8720, LAN8187,
> LAN8700, LAN83C185) provide a mechanism to conserve power when
> the device is not connected to an active link partner
> (Energy Detect Mode).
> So this patch enables the Energy Detect power-down mode
> for these Transceivers.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Both phy_read() and phy_write() can return errors, you must check
for them.  The rest of this driver does this properly.

