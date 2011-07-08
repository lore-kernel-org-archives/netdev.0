From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Simplify ARP hash function.
Date: Fri, 08 Jul 2011 15:32:58 -0700 (PDT)
Message-ID: <20110708.153258.1997707802176810939.davem@davemloft.net>
References: <CAL1RGDWbCi_nE8tRp9zyX3Z1yBHKP9ygxNV6TNKp4Up+0g2EPA@mail.gmail.com>
	<20110708.122742.1006323245708104141.davem@davemloft.net>
	<CAL1RGDWTfchzBSv9rbgfg5DWvqB-Gi-RBpzDPGRUg96fNcf4Bw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnwheffner@gmail.com, mj@ucw.cz, netdev@vger.kernel.org
To: roland@purestorage.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48626 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352Ab1GHWdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 18:33:09 -0400
In-Reply-To: <CAL1RGDWTfchzBSv9rbgfg5DWvqB-Gi-RBpzDPGRUg96fNcf4Bw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@purestorage.com>
Date: Fri, 8 Jul 2011 13:44:42 -0700

> The answer is that you have to mix hash_rnd into the hash
> in a nonlinear way, so that an attacker can't know if two values
> end up in the same bucket or not.
> 
> With your hash function, the attacker can just compute the
> hash (without hash_rnd) for all the values of key ^ ifindex
> and then use all the values that end up in the same bucket.

Ok, thanks everyone for explaining things.

So what is the cheapest non-linear function we could use?
