From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH v2 3/5] alx: add stats update function
Date: Sun, 5 Jan 2014 00:16:32 +0100
Message-ID: <20140104231632.GA32402@kria>
References: <1388854031-24142-1-git-send-email-sd@queasysnail.net>
 <1388854031-24142-4-git-send-email-sd@queasysnail.net>
 <20140104141608.5d882082@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: davem@davemloft.net, bhutchings@solarflare.com,
	johannes@sipsolutions.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:35046 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754944AbaADXQq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 18:16:46 -0500
Content-Disposition: inline
In-Reply-To: <20140104141608.5d882082@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[2014-01-04] Stephen Hemminger wrote:
> On Sat,  4 Jan 2014 17:47:09 +0100
> Sabrina Dubroca <sd@queasysnail.net> wrote:
> 
> >  }
> > +
> > +void __alx_update_hw_stats(struct alx_hw *hw)
> 
> Minor NIT:
> Why __ prefix? that is usually reserved for functions only
> called from one file (or when wrapping an existing API)

In the original code, that's the name it had, so I just kept it. There
were two additional wrappers, but in Johannes's rewrite of the driver,
they became unnecessary.
I'll rename it to alx_update_hw_stats in v3.


I didn't know about that convention. I can't find a reference in
Documentation/CodingStyle, or from a quick look at a grep in the rest
of the files there: maybe it should be added to the documentation?


Thanks,

-- 
Sabrina
