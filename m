From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: Add l3mdev rule
Date: Thu, 02 Jun 2016 18:12:51 -0400 (EDT)
Message-ID: <20160602.181251.1953990558401211774.davem@davemloft.net>
References: <1464840894-12697-1-git-send-email-dsa@cumulusnetworks.com>
	<1464840894-12697-2-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932954AbcFBWMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 18:12:53 -0400
In-Reply-To: <1464840894-12697-2-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed,  1 Jun 2016 21:14:53 -0700

> @@ -76,6 +76,7 @@ static int fib4_rule_action(struct fib_rule *rule, struct flowi *flp,
>  {
>  	int err = -EAGAIN;
>  	struct fib_table *tbl;
> +	u32 tb_id = fib_rule_get_table(rule, arg);

Please order local variable lines from longest to shortest.
