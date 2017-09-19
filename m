From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 07/14] gtp: Support encapsulation of IPv6 packets
Date: Tue, 19 Sep 2017 20:12:45 +0800
Message-ID: <20170919121245.t555dqwndhewmdyw@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-8-tom@quantonium.net>
 <20170918.211908.2152170523885516973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tom@quantonium.net, netdev@vger.kernel.org, pablo@netfilter.org,
        rohit@quantonium.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:45324 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdISMNN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 08:13:13 -0400
Content-Disposition: inline
In-Reply-To: <20170918.211908.2152170523885516973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

On Mon, Sep 18, 2017 at 09:19:08PM -0700, David Miller wrote:

> > +static inline u32 ipv6_hashfn(const struct in6_addr *a)
> > +{
> > +	return __ipv6_addr_jhash(a, gtp_h_initval);
> > +}
> 
> I know you are just following the pattern of the existing "ipv4_hashfn()" here
> but this kind of stuff is not very global namespace friendly.  Even simply
> adding a "gtp_" prefix to these hash functions would be a lot better.

I would agree if this was an inline function defined in a header file or
a non-static function.  But where is the global namespace concern in
case of static inline functions defined and used in the same .c file?

If it makes you happy, I'm all for adding the prefix - I just would like
to understand the rationale better, thanks :)

Regards,
	Harald
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
