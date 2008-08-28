From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Thu, 28 Aug 2008 22:55:29 +0300
Message-ID: <200808282255.29640.denys@visp.net.lb>
References: <20080827.201020.17601834.davem@davemloft.net> <200808282225.57535.denys@visp.net.lb> <48B6FE6C.4080905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Joe Malicki <jmalicki@metacarta.com>,
	David Miller <davem@davemloft.net>, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	juhlenko@akamai.com, sammy@sammy.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:54703 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482AbYH1T44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 15:56:56 -0400
In-Reply-To: <48B6FE6C.4080905@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 August 2008, Eric Dumazet wrote:
> OK, please try oprofile with call graph analysis.
I did already. Even because most of programs (except ripd/zebra) can be 
killed, and i kill them, it doesn't change almost anything.

it seems heavy things causing instability:

1)HTB (resolution can be lowered to improve performance, i will try Jarek 
patch soon)
2)ocassionally ping/tcpdump other SO_TIMESTAMP users
3)Probably softlockup detection. Disabled already, i will come back to it 
soon, if it is required.

One of other issues i notice - "CACHE MISS" cause maybe almost 5-10% in 
oprofile in u32, but i am not sure it is interesting subject to discuss. I 
have to optimize all my iproute2 rules first.

