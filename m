From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Fixed up ipsec packet be re-routing issue
Date: Wed, 11 Jun 2014 00:47:52 -0700 (PDT)
Message-ID: <20140611.004752.1241689531611946239.davem@davemloft.net>
References: <1402288645-6904-1-git-send-email-huizhang@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alan@lxorguk.ukuu.org.uk,
	sergei.shtylyov@cogentembedded.com, nickcave.zhang@gmail.com
To: huizhang@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbaFKHry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 03:47:54 -0400
In-Reply-To: <1402288645-6904-1-git-send-email-huizhang@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hui Zhang <huizhang@marvell.com>
Date: Mon, 9 Jun 2014 12:37:25 +0800

> Bug report on https://bugzilla.kernel.org/show_bug.cgi?id=75781
> 
> When a local output ipsec packet match the mangle table rule,
> and be set mark value, the packet will be route again in
> route_me_harder -> _session_decoder6
> 
> In this case, the nhoff in CB of skb was still the default
> value 0. So the protocal match can't success and the packet can't match
> correct SA rule,and then the packet be send out in plaintext.
> 
> To fixed up the issue. The CB->nhoff must be set.
> 
> Signed-off-by: Hui Zhang <huizhang@marvell.com>

Applied, thanks.
