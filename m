From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/6] gtp: misc improvements
Date: Tue, 31 Jan 2017 13:05:43 -0500 (EST)
Message-ID: <20170131.130543.246760553501896069.davem@davemloft.net>
References: <20170130163713.17524-1-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org, laforge@gnumonks.org,
        Lionel.Gauthier@eurecom.fr, openbsc@lists.osmocom.org
To: aschultz@tpip.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39590 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751997AbdAaSFp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:05:45 -0500
In-Reply-To: <20170130163713.17524-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Schultz <aschultz@tpip.net>
Date: Mon, 30 Jan 2017 17:37:07 +0100

> Resent as v2, because I forgot the net-next target. Sorry for noise,
> I promise I won't forget it again.
> 
> This series lays the groundwork for removing the socket references from
> the GTP netdevice by removing duplicate code and simplifying the logic on
> some code paths.
> 
> It slighly changes the GTP genl API by making the socket parameters optional
> (though one of them is still required).
> 
> The removal of the socket references will break the 1:1 releation between
> GTP netdevice and GTP socket that prevents us to support multiple VRFs with
> overlaping IP addresse spaces attached to the same GTP socket (needed for
> multi APN support).

This series is being held up it is not being reviewed.

Please someone with GTP knowledge properly review this series.

Thank you.
