From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v6 net-next 1/2] net: add skb_mstamp infrastructure
Date: Wed, 26 Feb 2014 12:29:22 -0800
Message-ID: <1393446562.26794.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1393290667.2316.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393292339.2316.98.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1393309324.2316.119.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140226.150246.2032724506200600118.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, ja@ssi.bg, ycheng@google.com,
	netdev@vger.kernel.org, ncardwell@google.com, brakmo@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:49082 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788AbaBZU3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:29:24 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so1422659pdi.35
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 12:29:23 -0800 (PST)
In-Reply-To: <20140226.150246.2032724506200600118.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-26 at 15:02 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>

> > + * skb_mstamp_delta - compute the difference in usec between two skb_mstamp
> > + * @t1: pointer to oldest sample
> > + * @t0: pointer to newest sample
> > + */
> > +static inline u32 skb_mstamp_us_delta(const struct skb_mstamp *t1,
> > +				      const struct skb_mstamp *t0)
> 
> Maybe your definition of "newest" is different from mine, to me it
> means most recently sampled.  And if so, your t1 and t0 descriptions
> seem reversed.
> 
> Please fix this and resubmit with Neal's ACK etc.

Humpf, right you are, I'll send a v6, thanks !
