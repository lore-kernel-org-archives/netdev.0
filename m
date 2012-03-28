From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] Ethernet driver for the WIZnet W5300 chip
Date: Wed, 28 Mar 2012 02:22:44 -0400 (EDT)
Message-ID: <20120328.022244.1736489266298072606.davem@davemloft.net>
References: <1332752876-1650-1-git-send-email-msink@permonline.ru>
	<20120327.223545.1996930432677091672.davem@davemloft.net>
	<4F72A72B.5020609@permonline.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: msink@permonline.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751699Ab2C1GWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 02:22:54 -0400
In-Reply-To: <4F72A72B.5020609@permonline.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Sinkovsky <msink@permonline.ru>
Date: Wed, 28 Mar 2012 11:52:43 +0600

> 28.03.2012 8:35, David Miller wrote:
> 
> From Documentation/netdev-features.txt:
> 
>>NETIF_F_VLAN_CHALLENGED should be set for devices which can't cope
>>with VLAN
>>headers. Some drivers set this because the cards can't handle the
>>bigger MTU.
>>[FIXME: Those cases could be fixed in VLAN code by allowing only
>>reduced-MTU
>>VLANs. This may be not useful, though.]
> 
> My case is exactly what is here in FIXME comment - yes, this chip
> cannot handle full size MTU for VLANs, and TCP/IP traffic don't work
> well over this VLAN.

I disagree with the comment in that document, I didn't write it.
