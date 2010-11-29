From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: fix stmmac_resume removing not yet used
 shutdown flag
Date: Sun, 28 Nov 2010 18:11:10 -0800 (PST)
Message-ID: <20101128.181110.71096427.davem@davemloft.net>
References: <1290740072-1341-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vlad.lungu@windriver.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46514
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754112Ab0K2CKo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 21:10:44 -0500
In-Reply-To: <1290740072-1341-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peppe CAVALLARO <peppe.cavallaro@st.com>
Date: Fri, 26 Nov 2010 15:11:45 +0100

> The commit to convert to use the dev_pm_ops struct
> introduces a bug. The shutdown flag is not yet used
> because the hibernation on memory is done by using
> the freeze callback.
> Thanks to Vlad for having reported it.
> 
> Reported-by: Vlad Lungu <vlad.lungu@windriver.com>
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

Applied.
