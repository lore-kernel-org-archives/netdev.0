From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Question about reading the routing table with netlink
Date: Wed, 11 Sep 2013 01:13:12 +0200
Message-ID: <20130910231312.GC4794@order.stressinduktion.org>
References: <522F2AF8.9080106@gont.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>
To: Fernando Gont <fernando@gont.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:49497 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700Ab3IJXNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 19:13:13 -0400
Content-Disposition: inline
In-Reply-To: <522F2AF8.9080106@gont.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 10, 2013 at 11:21:44AM -0300, Fernando Gont wrote:
> Folks,
> 
> Short version of the question:
> I'm trying to loop up a routing table entry with a
> socket(AF_NETLINK,SOCK_RAW,NETLINK_ROUTE).
> 
> Everything seems fine, except that I do not quite understand what's the
> effect of setting the RTA_SRC attribute type when doing that.

It sets the source address for the routing table lookup. This is important if
e.g. rules are specified or if ipv6 subtrees are in use.

> Empirically, it seems that if the RTA_SRC attribute is set and it
> contains an address that is assigned to the interface involved in the
> route, then such address is later returned in the reply as an RTA_SRC
> attribute.

Hm, I thought that RTA_SRC only has a semantic in the request and is moslty
just copied over to the response.

Greetings,

  Hannes
