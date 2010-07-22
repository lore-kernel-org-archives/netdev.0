From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] stmmac: handle allocation errors in setup
 functions
Date: Thu, 22 Jul 2010 14:13:24 -0700 (PDT)
Message-ID: <20100722.141324.76106225.davem@davemloft.net>
References: <20100722111648.GD17585@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47940
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758238Ab0GVVNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 17:13:08 -0400
In-Reply-To: <20100722111648.GD17585@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 22 Jul 2010 13:16:48 +0200

> If the allocations fail in either dwmac1000_setup() or dwmac100_setup()
> then return NULL.  These are called from stmmac_mac_device_setup().  The 
> check for NULL returns in stmmac_mac_device_setup() needed to be moved 
> forward a couple lines.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
