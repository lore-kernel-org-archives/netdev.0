From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: add suspend/resume into the PHY drivers
Date: Fri, 28 Nov 2008 16:36:04 -0800 (PST)
Message-ID: <20081128.163604.31265829.davem@davemloft.net>
References: <1227794239-19897-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38210
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753176AbYK2AgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 19:36:03 -0500
In-Reply-To: <1227794239-19897-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Thu, 27 Nov 2008 14:57:19 +0100

> almost all physical device drivers should be able to support power management.
> So this patch only adds the generic suspend/resume within them.
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

An easier way to do this would be to check for a NULL suspend
and resume method at PHY register time, and assign the
genphy variants if so.

But first you would implement and hookup the exceptions so that they
would not appear NULL in this situation.

Could you please reimplement this patch that way?

Also, you have a driver in your tree which does not exist upstream,
drivers/net/phy/national.c, so this patch wouldn't apply correctly
anyways.

Always do your development against the current networking development
tree:

	master.kernel.org:/pub/scm/linux/kernel/git/davem/net-next-2.6.git
