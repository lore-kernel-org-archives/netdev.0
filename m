From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/7] fix dev->addr_assign_type setting and
 related code
Date: Thu, 03 Jan 2013 22:43:38 -0800 (PST)
Message-ID: <20130103.224338.1365826037736788020.davem@davemloft.net>
References: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	sassmann@redhat.com, kaber@trash.net, richard@nod.at
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab3ADGnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 01:43:41 -0500
In-Reply-To: <1357047019-1037-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  1 Jan 2013 14:30:12 +0100

> commit c1f79426e2df5ef96fe3e76de6c7606d15bf390b introduced addr_assign_type,
> but incorrectly works with the value as if it was a bitfield. This patch corrects this.
> 
> Also, new "assign_type" is added to track that the address was changed by
> dev_set_mac_address().

Series applied, thanks Jiri.
