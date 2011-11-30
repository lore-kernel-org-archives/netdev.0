From: Julian Anastasov <ja@ssi.bg>
Subject: Re: ipv4: broadcast sometimes leaves wrong interface (since commit
 e066008b38ca9ace1b6de8dbbac8ed460640791d)
Date: Wed, 30 Nov 2011 02:56:40 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1111300148400.2328@ja.ssi.bg>
References: <1322585087.25018.115.camel@icts-sp-039> <alpine.LFD.2.00.1111300010150.2020@ja.ssi.bg> <20111129.182333.365445684859306013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jeroen@zijndomein.nl, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:34166 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753269Ab1K3A4A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Nov 2011 19:56:00 -0500
In-Reply-To: <20111129.182333.365445684859306013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Tue, 29 Nov 2011, David Miller wrote:

> From: Julian Anastasov <ja@ssi.bg>
> Date: Wed, 30 Nov 2011 01:06:46 +0200 (EET)
> 
> > 	May be the solution is to convert inet_addr_lst
> > from hlist to normal list, so that we can append new
> > addresses at tail and __ip_dev_find to find the first
> > device where IP was added.
> 
> Sure, but do we really want to guarentee this behavior forever?

	I remember for such issue with ipsec%d interfaces
years ago. May be the PPP servers should be configured
to use another local IP for PPP devices because broadcasts
and multicasts may need their own local address - they can use
addresses to refer to output devices.

	Not sure what else we can do, now we have to waste
1-2KB for this to work before someone recreates the eth
addresses and changes the ordering.

Regards

--
Julian Anastasov <ja@ssi.bg>
