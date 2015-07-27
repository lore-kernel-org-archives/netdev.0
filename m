From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: use lwtunnel_output6() only if flag
 redirect is set
Date: Mon, 27 Jul 2015 01:01:33 -0700 (PDT)
Message-ID: <20150727.010133.983985290760368449.davem@davemloft.net>
References: <1437728381-4603-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tgraf@suug.ch, roopa@cumulusnetworks.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38957 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750723AbbG0IBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:01:34 -0400
In-Reply-To: <1437728381-4603-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 24 Jul 2015 10:59:41 +0200

> This function make sense only when LWTUNNEL_STATE_OUTPUT_REDIRECT is set.
> The check is already done in IPv4.
> 
> CC: Thomas Graf <tgraf@suug.ch>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> Fixes: 74a0f2fe8ed5 ("ipv6: rt6_info output redirect to tunnel output")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks.
