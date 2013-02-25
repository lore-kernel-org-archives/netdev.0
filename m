From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2 v2] IP_GRE: Fix IP-Identification.
Date: Mon, 25 Feb 2013 15:48:47 -0500 (EST)
Message-ID: <20130225.154847.1374363747439708304.davem@davemloft.net>
References: <1361554230-1645-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jesse@nicira.com,
	stephen@networkplumber.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56062 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758826Ab3BYUst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2013 15:48:49 -0500
In-Reply-To: <1361554230-1645-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Fri, 22 Feb 2013 09:30:30 -0800

> GRE-GSO generates ip fragments with id 0,2,3,4... for every
> GSO packet, which is not correct. Following patch fixes it
> by setting ip-header id unique id of fragments are allowed.
> As Eric Dumazet suggested it is optimized by using inner ip-header
> whenever inner packet is ipv4.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied.
