From: Nick Hilliard <nick@inex.ie>
Subject: Re: [PATCH 1/3] IPv6: Generic TTL Security Mechanism (original version)
Date: Mon, 05 Apr 2010 20:06:17 +0100
Message-ID: <4BBA34A9.6080802@inex.ie>
References: <20100403232103.923025940@vyatta.com> <20100403232922.489187907@vyatta.com> <4BB96B9A.3000203@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, davem@davemloft.net,
	Pekka Savola <pekkas@netcore.fi>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.acquirer.com ([87.198.142.193]:49615 "EHLO
	mail.acquirer.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756104Ab0DEThT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 15:37:19 -0400
In-Reply-To: <4BB96B9A.3000203@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2010 05:48, YOSHIFUJI Hideaki wrote:
> I am for 1/3 (original), not for 2/3, 3/3.
>
> Because we should allow users to set respective value
> for IPv4 and IPv6, as we allow users to do so for TTL
> and hoplimit itself.

<non-linux-user>

I concur.  ipv4 mapped addresses need special handling in lots of cases, 
and I don't believe that patch 2/3 adds anything here - except possibly 
confusion.

Regarding case 3/3, ipv4 and ipv6 are separate protocols.  Treating them 
as the same from the setsockopt() point of view is a clear case of the 
Wrong Thing.

</non-linux-user>

Case 1/3 is IMO a better approach.  It satisfies both KISS (keep it 
simple...) and POLA (principle of least astonishment).

Nick
