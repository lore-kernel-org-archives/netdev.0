From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] fib_rules: add .suppress operation
Date: Tue, 30 Jul 2013 00:03:06 -0700 (PDT)
Message-ID: <20130730.000306.1057653828787681847.davem@davemloft.net>
References: <20130727070758.GA23904@order.stressinduktion.org>
	<20130730065317.GH13357@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	bsderandrew@gmail.com
To: stefan.tomanek@wertarbyte.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638Ab3G3HDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 03:03:07 -0400
In-Reply-To: <20130730065317.GH13357@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Date: Tue, 30 Jul 2013 08:53:17 +0200

> @@ -101,6 +101,17 @@ errout:
>  	return err;
>  }
>  
> +static bool fib4_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg) {
 ...
> @@ -119,6 +119,18 @@ out:
>  	return err;
>  }
>  
> +static bool fib6_rule_suppress(struct fib_rule *rule, struct fib_lookup_arg *arg) {
> +	struct rt6_info *rt = (struct rt6_info *) arg->result;
> +	/*
> +	 * do not accept result if the route does
> +	 * not meet the required prefix length
> +	 */


Please format this stuff correctly.

Functions are declared like this:

static type NAME(TYPE ARG1, TYPE ARG2)
{
}

You don't put the openning curly brace at the end of the line with the
closing parenthesis of the argument list.

Next, comments are to be formatted:

	/* Like
	 * this.
	 */

Thanks.
