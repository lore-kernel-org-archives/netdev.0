From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gre: reject GUE and FOU in collect metadata mode
Date: Thu, 28 Apr 2016 17:10:00 -0400 (EDT)
Message-ID: <20160428.171000.1223589001547447013.davem@davemloft.net>
References: <7280f5aa7ec83653cdf7f0484fb9e696bc8c89e8.1461758705.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@ovn.org, tgraf@suug.ch,
	tom@herbertland.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753230AbcD1VKB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 17:10:01 -0400
In-Reply-To: <7280f5aa7ec83653cdf7f0484fb9e696bc8c89e8.1461758705.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed, 27 Apr 2016 14:08:01 +0200

> The collect metadata mode does not support GUE nor FOU. This might be
> implemented later; until then, we should reject such config.
> 
> I think this is okay to be changed. It's unlikely anyone has such
> configuration (as it doesn't work anyway) and we may need a way to
> distinguish whether it's supported or not by the kernel later.
> 
> For backwards compatibility with iproute2, it's not possible to just check
> the attribute presence (iproute2 always includes the attribute), the actual
> value has to be checked, too.
> 
> Fixes: 2e15ea390e6f4 ("ip_gre: Add support to collect tunnel metadata.")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> Discovered this only after I already sent v3 of the previous gre set.
> Submitting this patch on its own, it's an indepent fix anyway (though fixing
> the same commit).

Applied, thank you.
