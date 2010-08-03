From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: RFC: New BGF 'LOOP' instruction
Date: Tue, 03 Aug 2010 11:10:28 +0200
Message-ID: <6809423e656a160df11216ea5acc3d8b@localhost>
References: <20100802201629.GA5973@nuttenaction>
 <20100802.221813.43045517.davem@davemloft.net>
 <20100803070709.GO11110@cel.leo>
 <20100803.001904.63020040.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: <leonerd@leonerd.org.uk>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:41854 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754106Ab0HCJK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 05:10:29 -0400
In-Reply-To: <20100803.001904.63020040.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 03 Aug 2010 00:19:04 -0700 (PDT), David Miller wrote:

> From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>



>> Rightnow, BPF is all but useless for parsing, say, IPv6. I only pick

>> IPv6 as one example, I'm sure there must exist a great number more

>> packet-based protocols that use a "linked-list" style approach to

>> headers. None of those are currently filterable on the current set of

>> instructions. LOOP would allow these.

> 

> It's not meant for detailed packet protocol header analysis,

> it's for stateless straight line matching of masked values

> in packet headers.



David is right, BPF cannot - and will not - keep with any high level

connection tracking packet filter. There is an processing trade-off between

packet classification and packet storage with post processing analysis.



Hagen
