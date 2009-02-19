From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] niu: fix PHY template choice for 10G copper
Date: Wed, 18 Feb 2009 17:53:01 -0800 (PST)
Message-ID: <20090218.175301.153945217.davem@davemloft.net>
References: <20090217103833.ec37526d.baranov@mercdev.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: baranov@mercdev.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54146
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753235AbZBSBxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 20:53:16 -0500
In-Reply-To: <20090217103833.ec37526d.baranov@mercdev.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Constantin Baranov <baranov@mercdev.com>
Date: Tue, 17 Feb 2009 10:38:33 +0400

> Fixed a typo in niu_determine_phy_disposition() which resulted in
> phy_template_1g_copper being selected for 10G/copper configuration.
> 
> Signed-off-by: Constantin Baranov <baranov@mercdev.com>

10g copper cards pretty much don't exist, which is probably why
nobody has hit this problem :-)

Patch applied, thanks.
