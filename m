From: Andreas Schultz <aschultz@tpip.net>
Subject: Re: [PATCH net-next v2 4/6] gtp: consolidate pdp context
 destruction into helper
Date: Mon, 13 Feb 2017 15:14:49 +0100 (CET)
Message-ID: <1516124800.96408.1486995289464.JavaMail.zimbra@tpip.net>
References: <20170130163713.17524-1-aschultz@tpip.net> <20170130163713.17524-5-aschultz@tpip.net> <20170206135859.mq6pidofidnps2q6@nataraja>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pablo <pablo@netfilter.org>, netdev <netdev@vger.kernel.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc <openbsc@lists.osmocom.org>
To: laforge <laforge@gnumonks.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:58173 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752270AbdBMOOv (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Feb 2017 09:14:51 -0500
In-Reply-To: <20170206135859.mq6pidofidnps2q6@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- On Feb 6, 2017, at 2:58 PM, laforge laforge@gnumonks.org wrote:

> Hi Andreas,
> 
> On Mon, Jan 30, 2017 at 05:37:11PM +0100, Andreas Schultz wrote:
>> Consolidate duplicate code into helper.
> 
> Makes complete sense.
> 
> However:
> 
>> +static void pdp_context_delete(struct pdp_ctx *pctx);
>> +
> 
> why introduce the forward-declaration and then define the function
> further down in the file?  I think in general, it is preferred to put
> helper functions on top, before their first use, so forward declarations
> can be avoided?  Particularly if the helper function doesn't call any
> other functions that are not yet declared at this point.

I wanted to keep functions that work on the data structure close
together. I this case the function the initialized the pdp context
and the delete function for it.

Andreas

> 
> Please note the above might just be my personal taste, not sure if
> that's a general habit in the kernel networking code these days.
> 
> So with or without the re-ordering:
> 
> Acked-by: Harald Welte <laforge@gnumonks.org>
> 
> --
> - Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
> ============================================================================
> "Privacy in residential applications is a desirable marketing option."
>                                                   (ETSI EN 300 175-7 Ch. A6)
