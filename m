From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 3/3] net: fullly using NETIF_F_ALL_TSO
Date: Fri, 22 Apr 2011 15:14:22 +0100
Message-ID: <1303481662.4129.24.camel@localhost>
References: <4DB16187.2030904@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, dm@chelsio.com, leedom@chelsio.com,
	benve@cisco.com, vkolluri@cisco.com, roprabhu@cisco.com,
	dwang2@cisco.com, ron.mercer@qlogic.com, linux-driver@qlogic.com,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:43985 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755876Ab1DVOO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 10:14:29 -0400
In-Reply-To: <4DB16187.2030904@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-22 at 19:07 +0800, Shan Wei wrote:
> Fullly using NETIF_F_ALL_TSO.
> And some code style tuning. Just compile test.
[...]

This is wrong.  What if some other TSO feature is defined and added to
NETIF_F_ALL_TSO later?  (This is unlikely, but hopefully you see that it
is conceptually wrong to claim 'all' features.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

