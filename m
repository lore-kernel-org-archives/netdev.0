From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] stmmac: unwind properly in stmmac_dvr_probe()
Date: Tue, 21 Dec 2010 10:53:30 -0800 (PST)
Message-ID: <20101221.105330.104073991.davem@davemloft.net>
References: <20101221073456.GG1936@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56327
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752482Ab0LUSxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 13:53:01 -0500
In-Reply-To: <20101221073456.GG1936@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Tue, 21 Dec 2010 10:34:56 +0300

> The original code had a several problems:
> *) It had potential null dereferences of "priv" and "res".
> *) It released the memory region before it was aquired.
> *) It didn't free "ndev" after it was allocated.
> *) It didn't call unregister_netdev() after calling stmmac_probe().
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Nice work, applied.

Thanks Dan.
