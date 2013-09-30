From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] vxlan: Use RCU apis to access sk_user_data.
Date: Mon, 30 Sep 2013 14:23:34 -0400 (EDT)
Message-ID: <20130930.142334.40594744645527066.davem@davemloft.net>
References: <1380043540-10417-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	stephen@networkplumber.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34956 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755187Ab3I3S0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Sep 2013 14:26:35 -0400
In-Reply-To: <1380043540-10417-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 24 Sep 2013 10:25:40 -0700

> Use of RCU api makes vxlan code easier to understand.  It also
> fixes bug due to missing ACCESS_ONCE() on sk_user_data dereference.
> In rare case without ACCESS_ONCE() compiler might omit vs on
> sk_user_data dereference.
> Compiler can use vs as alias for sk->sk_user_data, resulting in
> multiple sk_user_data dereference in rcu read context which
> could change.
> 
> CC: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Applied, thanks Pravin.
