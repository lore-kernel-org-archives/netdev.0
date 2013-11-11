From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] xfrm: Add check to prevent un-complete key
 manager
Date: Mon, 11 Nov 2013 14:04:13 -0500 (EST)
Message-ID: <20131111.140413.1835946304303785565.davem@davemloft.net>
References: <1384093556-8987-1-git-send-email-baker.kernel@gmail.com>
	<1384151951-13549-1-git-send-email-baker.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, steffen.klassert@secunet.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: baker.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56861 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755027Ab3KKTEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 14:04:15 -0500
In-Reply-To: <1384151951-13549-1-git-send-email-baker.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: baker.kernel@gmail.com
Date: Mon, 11 Nov 2013 14:39:11 +0800

> +	if (km->acquire == NULL || km->compile_policy == NULL)
> +		return -EINVAL;

There are 7 function pointer methods that must be fully implemented
in an xfrm_mgr object, not just two.

And really we absolutely do not care at all about your out-of-tree
product, it has no bearing upon what should happen here.
