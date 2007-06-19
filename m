From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Fix MTU calculation for non-ESP SAs
Date: Tue, 19 Jun 2007 14:02:30 +0200
Message-ID: <4677C5D6.20005@trash.net>
References: <4676AE27.8020504@trash.net> <20070618.223101.39174669.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pupilla@hotmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56414 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756005AbXFSMCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 08:02:48 -0400
In-Reply-To: <20070618.223101.39174669.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 18 Jun 2007 18:09:11 +0200
> 
> 
>>[XFRM]: Fix MTU calculation for non-ESP SAs
>>
>>My IPsec MTU optimization patch introduced a regression in MTU calculation
>>for non-ESP SAs, the SA's header_len needs to be subtracted from the MTU if
>>the transform doesn't provide a ->get_mtu() function.
>>
> 
> Patch applied, thanks a lot Patrick.
> 
> We only need this for 2.6.22 right?


Yes, the patch that broke this went into the first 2.6.22-rc.
