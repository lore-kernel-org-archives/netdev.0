From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/18] gtp: fixes and support multiple VRF's per GTP
 socket
Date: Tue, 24 Jan 2017 11:46:55 -0500 (EST)
Message-ID: <20170124.114655.1282086171761676213.davem@davemloft.net>
References: <20170124152848.6120-1-aschultz@tpip.net>
        <20170124153919.zkigaq55kykyrfq5@nataraja>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aschultz@tpip.net, pablo@netfilter.org, netdev@vger.kernel.org,
        Lionel.Gauthier@eurecom.fr, openbsc@lists.osmocom.org
To: laforge@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49614 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdAXQq5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 11:46:57 -0500
In-Reply-To: <20170124153919.zkigaq55kykyrfq5@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harald Welte <laforge@netfilter.org>
Date: Tue, 24 Jan 2017 16:39:19 +0100

> Hi Andreas,
> 
> On Tue, Jan 24, 2017 at 04:28:30PM +0100, Andreas Schultz wrote:
>> During that work some smaller problems where found and fixes for them are
>> included.
> 
> As this is a rather large patch-set, and I think it might be better to
> split it in clear bugfixes of the existing code (or no-brainers like the
> module alias) and in introducing new featur regarding socket/netdev.
> However, that's just my comment "from the side", I'm not the one who
> needs to be convinced in terms of merging them :)
> 
> I would just assume that the clear fixes + no-brainers could go in right
> away without any further review...

Yes, please split this stuff up, the patch series is _way_ too large.

Anything more than a dozen patches is way too much to burdon reviewers
with at one time.
