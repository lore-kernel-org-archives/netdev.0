From: Rafael Aquini <aquini@linux.com>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files.
Date: Fri, 6 May 2011 11:56:04 -0300
Message-ID: <20110506145602.GA5591@x61.tchesoft.com>
References: <20110506115037.GA3299@x61.tchesoft.com>
 <20110506150114.25513c92@absol.kitzblitz>
Reply-To: aquini@linux.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Joe Perches <joe@perches.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Nicolas Kaiser <nikai@nikai.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:41506 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753705Ab1EFO7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2011 10:59:41 -0400
Content-Disposition: inline
In-Reply-To: <20110506150114.25513c92@absol.kitzblitz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy Nicolas,

On Fri, May 06, 2011 at 03:01:14PM +0200, Nicolas Kaiser wrote:
> The indentation of parentheses looks correct to me in the original version.
> However, this expression can also be simplified like
> 
>                 if (active && active->lag_ports &&
>                     active->lag_ports->is_enabled &&
> -                   (__agg_has_partner(active) ||
> -                    (!__agg_has_partner(active) && !__agg_has_partner(best)))) {
> +                   (__agg_has_partner(active) || !__agg_has_partner(best))) {
>                         if (!(!active->actor_oper_aggregator_key &&
>                               best->actor_oper_aggregator_key)) {
>                                 best = NULL;
> 
> Last October I submitted such a patch which also simplified the
> double negation in the subsequent expression.

Thanks for the feedback!

Send me this patch of yours, I'll try to merge our paths and resubmit adding
you as a signer as well 

Cheers!
-- 
Rafael Aquini <aquini@linux.com>
