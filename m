From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv4: ip_send_unicast_reply should set oif only
 if it is L3 master
Date: Wed, 09 Nov 2016 21:48:24 -0500 (EST)
Message-ID: <20161109.214824.929135741139951182.davem@davemloft.net>
References: <1478645431-7454-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48212 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751546AbcKJCs0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 21:48:26 -0500
In-Reply-To: <1478645431-7454-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue,  8 Nov 2016 14:50:31 -0800

> Lorenzo noted an Android unit test failed due to commit e0d56fdd7342:
>   "The expectation in the test was that the RST replying to a SYN sent to a
>   closed port should be generated with oif=0. In other words it should not
>   prefer the interface where the SYN came in on, but instead should follow
>   whatever the routing table says it should do."
> 
> Since this a change in behavior, revert the change to
> ip_send_unicast_reply such that the oif in the flow is set to the skb_iif
> only if skb_iif is an L3 master.
> 
> Fixes: e0d56fdd7342 ("net: l3mdev: remove redundant calls")
> Reported-by: Lorenzo Colitti <lorenzo@google.com>
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

David, I'm assuming that a new spin of this patch is coming.
