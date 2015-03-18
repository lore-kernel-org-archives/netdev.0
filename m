From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] of_net: factor out repetitive code from
 of_get_mac_address()
Date: Wed, 18 Mar 2015 15:29:33 -0400 (EDT)
Message-ID: <20150318.152933.636562640494674435.davem@davemloft.net>
References: <1776166.J84mUn2Yu8@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbbCRT3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 15:29:35 -0400
In-Reply-To: <1776166.J84mUn2Yu8@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Wed, 18 Mar 2015 22:25:46 +0300

> of_get_mac_address() basically does the same  thing thrice, every  time with  a
> different  property  name,  so it makes sense to factor out the repetitive code
> into separate function. While at it, we can start using ETH_ALEN instead of the
> bare number and drop unnecessary parens around the property length check.
> 
> The resulting ARM object file is 100 bytes less in size than before the patch.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> The patch is against Grant Likely's 'linux.git' repo's 'devicetree/next' branch.

Acked-by: David S. Miller <davem@davemloft.net>
