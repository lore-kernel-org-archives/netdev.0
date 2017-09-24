From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 03/14] gtp: Call common functions to get tunnel
 routes and add dst_cache
Date: Sun, 24 Sep 2017 09:33:25 +0800
Message-ID: <20170924013325.7ywkdfdlzeflsbl2@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-4-tom@quantonium.net>
 <20170918.211751.1871429944584121281.davem@davemloft.net>
 <20170919120942.dpy5kmkhzws7pqd5@nataraja>
 <01c68c74-455c-9bff-e5bb-b1708d8f92f4@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, tom@quantonium.net,
        netdev@vger.kernel.org, pablo@netfilter.org, rohit@quantonium.net
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:60251 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdIXBkO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 21:40:14 -0400
Content-Disposition: inline
In-Reply-To: <01c68c74-455c-9bff-e5bb-b1708d8f92f4@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andreas,

On Wed, Sep 20, 2017 at 05:37:52PM +0200, Andreas Schultz wrote:
> I think we had this discussion before. The sending IP and port are not part
> of the identity of the PDP context. So IMHO the sender is permitted
> to change the source IP at random.

Thanks for the reminder: You are correct, at least in the uplink case
(MS->GGSN) where there is mobility of the MS. In the downlink case
(GGSN->MS), which is the "sending" part for the kernel GTP code used at
a GGSN, I'm not sure if that theory holds true in reality.

Do you agree that the current behavior of not using automatic source
address selection for encapsulated GTP packets but rather using the
source address of the socket is intended?

Do you further agree that the dst_cache support patch by Tom retains
that intended behavior and it should be merged?

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
