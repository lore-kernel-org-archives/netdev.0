From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: priv->lock can be used uninitialized
Date: Thu, 02 Dec 2010 13:19:59 -0800 (PST)
Message-ID: <20101202.131959.70193435.davem@davemloft.net>
References: <9345448e435110e2bdff65bb4322060a6f1f6b63.1291106902.git.vlad.lungu@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, peppe.cavallaro@st.com
To: vlad.lungu@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51507
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757178Ab0LBVTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 16:19:32 -0500
In-Reply-To: <9345448e435110e2bdff65bb4322060a6f1f6b63.1291106902.git.vlad.lungu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Lungu <vlad.lungu@windriver.com>
Date: Tue, 30 Nov 2010 10:52:52 +0200

> To reproduce: if connman (http://connman.net/) is started,
> inserting the stmmac module triggers a "BUG: spinlock bad magic on CPU#0".
> 
> Registering the device in stmmac_probe() sends a notification to connman
> which brings the interface up before the lock is initialized.
> 
> Signed-off-by: Vlad Lungu <vlad.lungu@windriver.com>

Applied, thanks.
