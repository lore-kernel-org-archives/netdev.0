From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next v5 0/7] gtp: misc improvements
Date: Mon, 13 Mar 2017 18:12:40 +0100
Message-ID: <20170313171240.4726igml4b3tm6ff@nataraja>
References: <20170309164302.13550-1-aschultz@tpip.net>
 <20170313164812.GA31925@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Schultz <aschultz@tpip.net>,
        osmocom-net-gprs@lists.osmocom.org, netdev <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:32859 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754206AbdCMRNF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 13:13:05 -0400
Content-Disposition: inline
In-Reply-To: <20170313164812.GA31925@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Pablo,

On Mon, Mar 13, 2017 at 05:48:12PM +0100, Pablo Neira Ayuso wrote:
> I would like you take the time to develop the VRF idea that you want
> to introduce, I just would like that we avoid bloating the GTP tunnel
> with features that we can just achieve via composite of different
> subsystems.

I presume you're talking about the "several APN behind one GGSN IP"
which requires the de-coupling of the UDP socket from the gtp
net-device?

I actually think it is a very straight forward idea what Andreas is
proposing, and I see no bloat associated.  It's rather like splitting
existing combined functionality in two parts, which can still be used
together, but also be used separately.

Or are you referring to something else?

In any case, I'm looking forward to the related technical discussion on
this mailing list[s] :)

Regards,
	Harald
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
