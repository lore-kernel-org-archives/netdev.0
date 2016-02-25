From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ppp: clarify parsing of user supplied data in
 ppp_set_compress()
Date: Wed, 24 Feb 2016 23:53:15 -0500 (EST)
Message-ID: <20160224.235315.1205744186191236308.davem@davemloft.net>
References: <4765fab0f32c4a2391828b8c418592f4a5bcede6.1456232225.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758167AbcBYE6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 23:58:05 -0500
In-Reply-To: <4765fab0f32c4a2391828b8c418592f4a5bcede6.1456232225.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Tue, 23 Feb 2016 13:59:43 +0100

>   * Split big conditional statement.
>   * Check (data.length <= CCP_MAX_OPTION_LENGTH) only once.
>   * Don't read ccp_option[1] if not initialised.
> 
> Reading uninitialised ccp_option[1] was harmless, because this could
> only happen when data.length was 0 or 1. So even then, we couldn't pass
> the (ccp_option[1] < 2 || ccp_option[1] > data.length) test anyway.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied, thanks.
