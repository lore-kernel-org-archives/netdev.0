From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/6] net: Generalize checksum_init functions
Date: Mon, 07 Apr 2014 13:12:41 -0400 (EDT)
Message-ID: <20140407.131241.254964708720144041.davem@davemloft.net>
References: <alpine.DEB.2.02.1404041717020.20947@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55085 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753190AbaDGRMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 13:12:43 -0400
In-Reply-To: <alpine.DEB.2.02.1404041717020.20947@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 4 Apr 2014 17:27:19 -0700 (PDT)

> +static inline __sum16 skb_checksum_init(struct sk_buff *skb, int proto,
> +		__wsum (*compute_pseudo)(struct sk_buff *skb, int proto)) {

Please Tom put the openning braces on a seperate line.

This goes for all of the new inlines you've created here.
