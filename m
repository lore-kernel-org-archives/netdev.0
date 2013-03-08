From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: Update link_up flag for phylib devices
Date: Thu, 07 Mar 2013 22:29:42 -0500 (EST)
Message-ID: <20130307.222942.936900451773665530.davem@davemloft.net>
References: <1362710727-15438-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hirofumi@mail.parknet.co.jp,
	mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49134 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784Ab3CHD3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 22:29:46 -0500
In-Reply-To: <1362710727-15438-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Thu, 7 Mar 2013 18:45:27 -0800

> Commit f4a46d1f46a8fece34edd2023e054072b02e110d introduced a bug where
> the ifconfig stats would remain 0 for phylib devices. This is due to
> tp->link_up flag never becoming true causing tg3_periodic_fetch_stats()
> to return.

This is a non-trivial regression, therefore shouldn't this change
be targetted at 'net' instead of 'net-next'?
