From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] RFC 4960 Errata fixes
Date: Sun, 25 Jun 2017 14:44:30 -0400 (EDT)
Message-ID: <20170625.144430.1405311499377880024.davem@davemloft.net>
References: <cover.1498251459.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42182 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751330AbdFYSou (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 14:44:50 -0400
In-Reply-To: <cover.1498251459.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Fri, 23 Jun 2017 19:58:39 -0300

> This patchset contains fixes for 4 Errata topics from
> https://tools.ietf.org/html/draft-ietf-tsvwg-rfc4960-errata-01
> Namely, sections:
>  3.12. Order of Adjustments of partial_bytes_acked and cwnd
>  3.22. Increase of partial_bytes_acked in Congestion Avoidance
>  3.26. CWND Increase in Congestion Avoidance Phase
>  3.27. Refresh of cwnd and ssthresh after Idle Period
> 
> Tests performed with netperf using net namespaces, with drop rates at
> 0%, 0.5% and 1% by netem, IPv4 and IPv6, 10 runs for each combination.
> I couldn't spot differences on the stats. With and without these patches
> the results vary in a similar way in terms of throughput and
> retransmissions.
> 
> Tests with 20ms delay and 20ms delay + drops at 0.5% and 1% also had
> results in a similar way, no noticeable difference.
> 
> Looking at cwnd, it was possible to notice slightly lower values being
> used while still sustaining same throughput profile.

Series applied, thank you.
