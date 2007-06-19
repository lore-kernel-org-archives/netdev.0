From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: Fix MTU calculation for non-ESP SAs
Date: Mon, 18 Jun 2007 22:31:01 -0700 (PDT)
Message-ID: <20070618.223101.39174669.davem@davemloft.net>
References: <4676AE27.8020504@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pupilla@hotmail.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55765
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752250AbXFSFan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 01:30:43 -0400
In-Reply-To: <4676AE27.8020504@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 18 Jun 2007 18:09:11 +0200

> [XFRM]: Fix MTU calculation for non-ESP SAs
> 
> My IPsec MTU optimization patch introduced a regression in MTU calculation
> for non-ESP SAs, the SA's header_len needs to be subtracted from the MTU if
> the transform doesn't provide a ->get_mtu() function.
> 
> Reported-and-tested-by: Marco Berizzi <pupilla@hotmail.com>
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Patch applied, thanks a lot Patrick.

We only need this for 2.6.22 right?
