From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/5] GRE: Refactor GRE tunneling code.
Date: Mon, 18 Mar 2013 15:24:30 -0400 (EDT)
Message-ID: <20130318.152430.2139279377420574326.davem@davemloft.net>
References: <1363630405-1672-1-git-send-email-pshelar@nicira.com>
	<20130318.152337.1168478029473094805.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60849 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753967Ab3CRTYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 15:24:32 -0400
In-Reply-To: <20130318.152337.1168478029473094805.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 18 Mar 2013 15:23:37 -0400 (EDT)

> From: Pravin B Shelar <pshelar@nicira.com>
> Date: Mon, 18 Mar 2013 11:13:25 -0700
> 
>> +EXPORT_SYMBOL(ip_tunnel_get_stats64);
> 
> EXPORT_SYMBOL_GPL() please.

In case it isn't clear, I want you to use GPL exports for all of the
symbols exported from the new library.

Thanks.
