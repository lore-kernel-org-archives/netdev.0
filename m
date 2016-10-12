From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] openvswitch: correctly fragment packet
 with mpls headers
Date: Wed, 12 Oct 2016 01:45:00 -0400 (EDT)
Message-ID: <20161012.014500.60370824227871899.davem@davemloft.net>
References: <502ca56422930442a91db61f975f829c62b27c7f.1475672359.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com, pshelar@ovn.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36682 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752427AbcJLFpD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 01:45:03 -0400
In-Reply-To: <502ca56422930442a91db61f975f829c62b27c7f.1475672359.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Wed,  5 Oct 2016 15:01:57 +0200

> If mpls headers were pushed to a defragmented packet, the refragmentation no
> longer works correctly after 48d2ab609b6b ("net: mpls: Fixups for GSO"). The
> network header has to be shifted after the mpls headers for the
> fragmentation and restored afterwards.
> 
> Fixes: 48d2ab609b6b ("net: mpls: Fixups for GSO")
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Applied.
