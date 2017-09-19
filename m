From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH net-next 04/14] gtp: udp recv clean up
Date: Tue, 19 Sep 2017 19:32:23 +0800
Message-ID: <20170919113223.ve3qvfgr7pmduif7@nataraja>
References: <20170919003904.5124-1-tom@quantonium.net>
 <20170919003904.5124-5-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, pablo@netfilter.org,
        rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:45344 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751543AbdISMNN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 08:13:13 -0400
Content-Disposition: inline
In-Reply-To: <20170919003904.5124-5-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

I think this patch does too many things at once:
* introduce separate rx functions
* convert from netif_rx to gro_cells_receive
* cosmetic changes like "return -1" to "goto drop"

In the context of reviewability and the "one patch per topic", I would
prefer to see those separated, thanks.

-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
