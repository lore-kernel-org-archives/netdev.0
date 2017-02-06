From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH net-next v2 2/6] gtp: merge gtp_get_net and
 gtp_genl_find_dev
Date: Mon, 6 Feb 2017 14:55:12 +0100
Message-ID: <20170206135512.sbxvkbe3hzgnwwjt@nataraja>
References: <20170130163713.17524-1-aschultz@tpip.net>
 <20170130163713.17524-3-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@netfilter.org>, netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:58531 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753249AbdBFOEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 09:04:39 -0500
Content-Disposition: inline
In-Reply-To: <20170130163713.17524-3-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

On Mon, Jan 30, 2017 at 05:37:09PM +0100, Andreas Schultz wrote:
> Both function are always used together with the final goal to
> get the gtp_dev. This simplifies the code by merging them together.

Ok, some code restructuring / unification, seems useful.

However:

> -			netdev_dbg(dev, "GTPv0-U: update tunnel id = %llx (pdp %p)\n",
> -				   pctx->u.v0.tid, pctx);
> +			pr_debug("GTPv0-U: update tunnel id = %llx (pdp %p)\n",
> +				 pctx->u.v0.tid, pctx);

(and other related changes) appear to be purely cosmetic and should thus
be unrelated to the function merging described in the change log
message.

-- 
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
============================================================================
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie
