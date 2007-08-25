From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPV4] IPSEC: Omit redirect for tunnelled packet.
Date: Fri, 24 Aug 2007 23:33:13 -0700 (PDT)
Message-ID: <20070824.233313.34382404.davem@davemloft.net>
References: <11879501412786-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45138
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759450AbXHYGdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 02:33:14 -0400
In-Reply-To: <11879501412786-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Fri, 24 Aug 2007 19:09:01 +0900

> IPv4 IPsec tunnel gateway incorrectly sends redirect to
> sender if it is onlink host when network device the IPsec tunnelled
> packet is arrived is the same as the one the decapsulated packet
> is sent.
> 
> With this patch, it omits to send the redirect when the forwarding
> skbuff carries secpath, since such skbuff should be assumed as
> a decapsulated packet from IPsec tunnel by own.
> 
> Request for comments:
> Alternatively we'd have another way to change net/ipv4/route.c
> (__mkroute_input) to use RTCF_DOREDIRECT flag unless skbuff
> has no secpath. It is better than this patch at performance
> point of view because IPv4 redirect judgement is done at
> routing slow-path. However, it should be taken care of resource
> changes between SAD(XFRM states) and routing table. In other words,
> When IPv4 SAD is changed does the related routing entry go to its
> slow-path? If not, it is reasonable to apply this patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Also applied, thank you!
