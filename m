From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6: sr: fix get_srh() to comply with IPv6
 standard "RFC 8200"
Date: Wed, 30 Aug 2017 15:19:47 -0700 (PDT)
Message-ID: <20170830.151947.1646224839367558973.davem@davemloft.net>
References: <1504083037-1605-1-git-send-email-amsalam20@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, david.lebrun@uclouvain.be
To: amsalam20@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35206 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750814AbdH3WTs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 18:19:48 -0400
In-Reply-To: <1504083037-1605-1-git-send-email-amsalam20@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ahmed Abdelsalam <amsalam20@gmail.com>
Date: Wed, 30 Aug 2017 10:50:37 +0200

> IPv6 packet may carry more than one extension header, and IPv6 nodes must
> accept and attempt to process extension headers in any order and occurring
> any number of times in the same packet. Hence, there should be no
> assumption that Segment Routing extension header is to appear immediately
> after the IPv6 header.
> 
> Moreover, section 4.1 of RFC 8200 gives a recommendation on the order of
> appearance of those extension headers within an IPv6 packet. According to
> this recommendation, Segment Routing extension header should appear after
> Hop-by-Hop and Destination Options headers (if they present).
> 
> This patch fixes the get_srh(), so it gets the segment routing header
> regardless of its position in the chain of the extension headers in IPv6
> packet, and makes sure that the IPv6 routing extension header is of Type 4.
> 
> Signed-off-by: Ahmed Abdelsalam <amsalam20@gmail.com>

Applied.
