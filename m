From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [RFC] GTSM for IPv6
Date: Fri, 19 Mar 2010 20:02:48 +0200 (EET)
Message-ID: <alpine.LRH.2.00.1003191959050.31512@netcore.fi>
References: <20100319095640.42c8d82d@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>,
	=?ISO-2022-JP?Q?YOSHIFUJI_Hideaki_=2F_=1B$B5HF#1QL=40=1B=28J?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:52367 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751849Ab0CSSDB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 14:03:01 -0400
In-Reply-To: <20100319095640.42c8d82d@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 19 Mar 2010, Stephen Hemminger wrote:
> Also RFC doesn't explicitly address GTSM on IPV6.
> Maybe the RFC editors think the problem will magically no longer exist
> in IPv6 world because everyone will be using IPsec.

Hmm. When I was editing the RFC, I seem to have put in some text about 
IPv6 (i.e. difference in TTL vs Hop Count naming).  As far as I know, 
there is no other difference :-)

In IPV6_MIN_HOPS hops would seem to point toward the "number of hops" 
which is logically the opposite: 255-$value.  So maybe 
IPV6_MIN_HOPCOUNT is better. But I can live with it either way :-)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
