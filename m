From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] sit: allow to switch netns during
 encap/decap
Date: Thu, 27 Jun 2013 22:36:21 -0700 (PDT)
Message-ID: <20130627.223621.1852663736303796496.davem@davemloft.net>
References: <51CADB72.3090206@6wind.com>
	<1372255888-4792-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36039 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132Ab3F1FgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jun 2013 01:36:22 -0400
In-Reply-To: <1372255888-4792-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 26 Jun 2013 16:11:26 +0200

> This patch is a follow up of the thread "switching network namespace midway":
> http://marc.info/?t=135101459500004&r=1&w=2
> 
> The goal of this serie is to add x-netns support for the module sit, ie the
> encapsulation addresses and the network device are not owned by the same
> namespace.

Ok, applied.

And yes I agree we should look into making tunnel's behave consistently
wrt. SKB orphaning, cleaning netfilter state, etc.
