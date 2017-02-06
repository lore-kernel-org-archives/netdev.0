From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH net-next v2 1/6] gtp: make GTP sockets in gtp_newlink
 optional
Date: Mon, 6 Feb 2017 14:51:09 +0100
Message-ID: <20170206135109.sw5p2yb7cbsa3g37@nataraja>
References: <20170130163713.17524-1-aschultz@tpip.net>
 <20170130163713.17524-2-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@netfilter.org>, netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:58537 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753257AbdBFOEj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 09:04:39 -0500
Content-Disposition: inline
In-Reply-To: <20170130163713.17524-2-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

my kernel coding skills are getting a bit rusty (no pun intended), and
I'll think others on this list are more capable to do so.  But let me at
least provide feedback from the "3GPP / GTP side":

On Mon, Jan 30, 2017 at 05:37:08PM +0100, Andreas Schultz wrote:
> Having both GTPv0-U and GTPv1-U is not always desirable.
> Fallback from GTPv1-U to GTPv0-U was depreciated from 3GPP
> Rel-8 onwards. Post Rel-8 implementation are discuraged
> from listening on the v0 port (see 3GPP TS 29.281, Sect. 1).

I confirm this and I think the related change should be applied.

> A future change will completely decouple the sockets from the
> network device. Till then, at least one of the sockets needs to
> be specified (either v0 or v1), the other is optional.

Makes sense.

-- 
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
============================================================================
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie
