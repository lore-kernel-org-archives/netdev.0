From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Fri, 19 Mar 2010 09:58:09 +0200 (EET)
Message-ID: <alpine.LRH.2.00.1003190837210.6428@netcore.fi>
References: <20100110220034.4d46ba8a@nehalam> <alpine.LRH.2.00.1003180833420.24946@netcore.fi> <20100318105939.57f8d377@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:43273 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460Ab0CSH6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Mar 2010 03:58:50 -0400
In-Reply-To: <20100318105939.57f8d377@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Mar 2010, Stephen Hemminger wrote:
>> The experimental, earlier spec (GTSH, RFC3682) did not have this
>> requirement.  Most if not all implementations support only GTSH mode.
>> So a backward-compatibility option may be desirable.
>
> The ICMP receive error handling does need to be updated.
>
> But any application using GTSM should be setting IP_TTL socket option
> to set send TTL. But, not sure if Linux TCP ever sends ICMP
> for existing sessions at all.

Thanks, Stephen!  It's nice to see at least one compliant RFC5082 
implementation ;-)

Good point that no one should should probably even be sending ICMP 
messages for TCP sockets, but on receive side the checks are important 
:-)

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
