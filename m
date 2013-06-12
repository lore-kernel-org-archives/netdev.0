From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/3] team: remove sychronize_rcu() calls
Date: Wed, 12 Jun 2013 03:10:22 -0700 (PDT)
Message-ID: <20130612.031022.382642269781263103.davem@davemloft.net>
References: <1370878945-9718-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, fbl@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52461 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103Ab3FLKKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 06:10:23 -0400
In-Reply-To: <1370878945-9718-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon, 10 Jun 2013 17:42:22 +0200

> Jiri Pirko (3):
>   team: remove synchronize_rcu() called during queue override change
>   team: use kfree_rcu instead of synchronize_rcu in team_port_dev
>   team: remove synchronize_rcu() called during port disable

Applied, but I suspect this patch series was generated against the
patch set you submitted for "net" because I had to hand apply patch
#3 with some fuzz as git would not apply it directly.

Please don't do that, submit your patches in the future against what
is actually in net-next.
