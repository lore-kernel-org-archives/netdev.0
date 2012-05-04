From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: be more strict before accepting ECN negociation
Date: Fri, 04 May 2012 11:09:31 -0700
Message-ID: <4FA41B5B.5080103@hp.com>
References: <1336144442.3752.348.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Perry Lorier <perryl@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Wilmer van der Gaast <wilmer@google.com>,
	=?UTF-8?B?RGF2ZSBUw6RodA==?= <dave.taht@bufferbloat.net>,
	Ankur Jain <jankur@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:9694 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517Ab2EDSJe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 14:09:34 -0400
In-Reply-To: <1336144442.3752.348.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2012 08:14 AM, Eric Dumazet wrote:
> From: Eric Dumazet<edumazet@google.com>
>
> It appears some networks play bad games with the two bits reserved for
> ECN. This can trigger false congestion notifications and very slow
> transferts.
>
> Since RFC 3168 (6.1.1) forbids SYN packets to carry CT bits, we can
> disable TCP ECN negociation if it happens we receive mangled CT bits in
> the SYN packet.

What sort of networks were these?  Any chance it was some sort of 
attempt to add ECN to FastOpen?

rick jones
