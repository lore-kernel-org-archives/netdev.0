From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 11 Jul 2006 11:22:18 +0200
Message-ID: <BAY103-F203CAD498C086FD90B8381B2680@phx.gbl>
References: <20060711064232.GA1490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s28.bay0.hotmail.com ([65.54.246.228]:15917 "EHLO
	bay0-omc3-s28.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1750863AbWGKJWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 05:22:21 -0400
In-Reply-To: <20060711064232.GA1490@gondor.apana.org.au>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>We can say these things for certain:
>
>1) The path between mimosa and pleiadi has a packet loss problem.  A small
>    burst of 10 or so fragments is enough to cause at least half of them to
>    be lost.  This problem may be specific to IPsec traffic (ISPs often
>    discriminate against traffic with protocols other than TCP/UDP).

This is my company network schema:

sap 
server---milano-network==mimosa-+-internet-+-pleiadi==venezia-network--sap 
client

I'm able to connect to a sap server connected to the milano network
from a sapgui client connected to the venezia network. No problem.
If packet loss is a problem it should be also a problem with this tunnel.
Am I wrong?


