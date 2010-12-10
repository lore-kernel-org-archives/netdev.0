From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: add the IC+ IP1001 driver
Date: Fri, 10 Dec 2010 15:47:41 -0800 (PST)
Message-ID: <20101210.154741.173841125.davem@davemloft.net>
References: <1291885513-32766-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33002
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751522Ab0LJXrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 18:47:13 -0500
In-Reply-To: <1291885513-32766-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 9 Dec 2010 10:05:13 +0100

> This patch adds the IC+ IP1001 (Gigabit Ethernet Transceiver) driver.
> I've had to add an additional delay (2ns) to adjust RX clock phase at
> GMII/ RGMII interface (according to the PHY data-sheet). This helps to
> have the RGMII working on some ST platforms.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

You forgot to update the icplus_tbl module device table with a
new 0x02430d90 entry.

Please fix this and resubmit.
