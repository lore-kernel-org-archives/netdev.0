From: Andi Kleen <ak@suse.de>
Subject: Re: determine outgoing interface (eth0,eth1) for a packet according to the dest IP
Date: Tue, 25 Apr 2006 16:48:09 +0200
Message-ID: <200604251648.10113.ak@suse.de>
References: <ada605fb0604250031r2e4a74e7id0b5079fabde9517@mail.gmail.com> <200604250943.49422.ak@suse.de> <ada605fb0604250744w73c7766as1d3ceb0d62511764@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:37324 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S932247AbWDYOs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 10:48:29 -0400
To: "John Que" <qwejohn@gmail.com>
In-Reply-To: <ada605fb0604250744w73c7766as1d3ceb0d62511764@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 25 April 2006 16:44, John Que wrote:
> Thanks a lot !
> 
>   I had tried the sending RTM_GETROUTE message using a NETLINK_ROUTE
> 	socket in a User Space program and it went OK.
> 	
> 	It gaves correct routing struct which I could parse.
> 	In fact it gave the rotuing table.
> 	But in sending that message I did not specify a certain
> 	dest IP.
> 	Consider the follwing simple scenario: I have 2 gateways
> 	(one on eth0,one on eth1), and I am sending
> 	a packet to some dest IP ; I want to know according to
> 	that ip on which interface (or gw) it will be out
> 	
> 	But where do I specify that certain dest IP ?

You add RTA_SRC and RTA_DST attributes to the query.

-Andi
