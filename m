From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next v2 2/6] gtp: merge gtp_get_net and
 gtp_genl_find_dev
Date: Mon, 13 Feb 2017 15:13:37 +0100 (CET)
Message-ID: <2072664575.96405.1486995217363.JavaMail.zimbra@tpip.net>
References: <20170130163713.17524-1-aschultz@tpip.net> <20170130163713.17524-3-aschultz@tpip.net> <20170206135512.sbxvkbe3hzgnwwjt@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pablo <pablo@netfilter.org>, netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc <openbsc@lists.osmocom.org>
To: Harald Welte <laforge@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:40314 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751818AbdBMONk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 09:13:40 -0500
In-Reply-To: <20170206135512.sbxvkbe3hzgnwwjt@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- On Feb 6, 2017, at 2:55 PM, Harald Welte laforge@netfilter.org wrote:

> Hi Andreas,
> 
> On Mon, Jan 30, 2017 at 05:37:09PM +0100, Andreas Schultz wrote:
>> Both function are always used together with the final goal to
>> get the gtp_dev. This simplifies the code by merging them together.
> 
> Ok, some code restructuring / unification, seems useful.
> 
> However:
> 
>> -			netdev_dbg(dev, "GTPv0-U: update tunnel id = %llx (pdp %p)\n",
>> -				   pctx->u.v0.tid, pctx);
>> +			pr_debug("GTPv0-U: update tunnel id = %llx (pdp %p)\n",
>> +				 pctx->u.v0.tid, pctx);
> 
> (and other related changes) appear to be purely cosmetic and should thus
> be unrelated to the function merging described in the change log
> message.

The dev argument has been removed from the surrounding function.
However, for those debug message having the network device information
is use full. I've modified the code in v3 a bit to keep the debug message.

Andreas

> 
> --
> - Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
> ============================================================================
>  "Fragmentation is like classful addressing -- an interesting early
>   architectural error that shows how much experimentation was going
>    on while IP was being designed."                    -- Paul Vixie
