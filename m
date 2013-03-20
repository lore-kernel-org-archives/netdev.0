From: David Miller <davem@davemloft.net>
Subject: Re: [regression] [analyzed] fragmentation broken for tunnel devices
Date: Wed, 20 Mar 2013 13:46:40 -0400 (EDT)
Message-ID: <20130320.134640.1857052324535652751.davem@davemloft.net>
References: <20130315133820.006a42f6@vostro>
	<20130315150321.621d705e@vostro>
	<20130320101318.4196d93a@vostro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59302 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754645Ab3CTRqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 13:46:42 -0400
In-Reply-To: <20130320101318.4196d93a@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Wed, 20 Mar 2013 10:13:18 +0200

Thanks for investigating this issue.

> 3) Reimplement fragmentation in tunnel devices. This means some
> duplication of code. But now that there's GRO support in tunnels, this
> would seem the most performant option.

I think this is the best option, especially in the long term.
