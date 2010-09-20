From: David Miller <davem@davemloft.net>
Subject: Re: E1000E/82567LM-3: link reported up too soon
Date: Mon, 20 Sep 2010 13:18:39 -0700 (PDT)
Message-ID: <20100920.131839.173838219.davem@davemloft.net>
References: <878w2wnsyd.fsf@small.ssi.corp>
	<20100920.125447.220082714.davem@davemloft.net>
	<87y6awjhxv.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52790
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757102Ab0ITUST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 16:18:19 -0400
In-Reply-To: <87y6awjhxv.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: arno@natisbad.org (Arnaud Ebalard)
Date: Mon, 20 Sep 2010 22:09:16 +0200

> The packets sent are an IPv6 Router Solicitation (to get IPv6 subnet
> prefixes from the router) and a DHCP Request (to get an IPv4 address
> from the DHCP server). 
> 
> The former is sent from the unspecified address (::) and the latter from
> 0.0.0.0. The former is sent by UMIP Mobile IPv6 daemon. The second by my
> DHCP client. They both use netlink to do that as soon as the link is up.
> Both are for address configuration ...

So do both DHCP request and the IPV6 RS get dropped, or just the IPV6 RS?
