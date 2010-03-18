From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] tcp: Generalized TTL Security Mechanism
Date: Thu, 18 Mar 2010 08:36:48 +0200 (EET)
Message-ID: <alpine.LRH.2.00.1003180833420.24946@netcore.fi>
References: <20100110220034.4d46ba8a@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:40400 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191Ab0CRGha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Mar 2010 02:37:30 -0400
In-Reply-To: <20100110220034.4d46ba8a@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, 10 Jan 2010, Stephen Hemminger wrote:
> This patch adds the kernel portions needed to implement
> RFC 5082 Generalized TTL Security Mechanism (GTSM).
> It is a lightweight security measure against forged
> packets causing DoS attacks (for BGP).
...

It's nice to see this added.  However, I must add that a compliant RFC 
5082 implementation is required to have similar TTL treatment for ICMP 
errors which relate to the protected session.  AFAIK this does not 
support that.

The experimental, earlier spec (GTSH, RFC3682) did not have this 
requirement.  Most if not all implementations support only GTSH mode. 
So a backward-compatibility option may be desirable.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
