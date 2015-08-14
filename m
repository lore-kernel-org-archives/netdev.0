From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ppp: fix device unregistration upon netns deletion
Date: Thu, 13 Aug 2015 21:19:03 -0700 (PDT)
Message-ID: <20150813.211903.1087274945593868388.davem@davemloft.net>
References: <d2b0363f2f54f5681c4c632b18617feb9ec0d8a9.1439469593.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbbHNETF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 00:19:05 -0400
In-Reply-To: <d2b0363f2f54f5681c4c632b18617feb9ec0d8a9.1439469593.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 13 Aug 2015 15:18:25 +0200

> +	idr_for_each_entry(&pn->units_idr, ppp, id) {
> +		unregister_netdevice_queue(ppp->dev, &list);
> +	}

Single line basic blocks should not use curly braces.  Please remove
them, thank you.
