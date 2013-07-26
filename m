From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 net-next] bridge: cleanup netpoll code
Date: Fri, 26 Jul 2013 15:25:17 -0700 (PDT)
Message-ID: <20130726.152517.339348132224694095.davem@davemloft.net>
References: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, jiri@resnulli.us, fubar@us.ibm.com,
	andy@greyhouse.net, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758073Ab3GZWZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 18:25:18 -0400
In-Reply-To: <20130724115141.63bba894@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 24 Jul 2013 11:51:41 -0700

> This started out with fixing a sparse warning, then I realized that
> the wrapper function br_netpoll_info could just be collapsed away
> by rolling it into the enable code.
> 
> Also, eliminate unnecessary goto's
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Applied.
