From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Mon, 31 Jul 2006 21:47:40 -0400
Message-ID: <1154396860.5170.51.camel@jzny2>
References: <E1G6Fic-0005py-00@gondolin.me.apana.org.au>
	 <20060727.183415.104032934.davem@davemloft.net>
	 <200608010231.58339.ak@suse.de>
	 <20060731.174641.99457765.davem@davemloft.net> <ada7j1t700x.fsf@cisco.com>
	 <1154395467.5170.31.camel@jzny2>
	 <20060801013033.GA1280@gondor.apana.org.au>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, kazunori@miyazawa.org, ak@suse.de,
	David Miller <davem@davemloft.net>,
	Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.znyx.com ([208.2.156.141]:63494 "EHLO mailhub.znyx.com")
	by vger.kernel.org with ESMTP id S1030215AbWHABrq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 21:47:46 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060801013033.GA1280@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-01-08 at 11:30 +1000, Herbert Xu wrote:

> 
> You can now disable the OOM killer on a per-process basis by
> 
> echo -17 > /proc/<pid>/oom_adj
> 

nice to know ;-> At least you can protect some apps if you need to.
Only racoon and quagga are important for me.
But what happens then if you have a beast that just chews memory
forever? I suppose other poor apps will just get shot.

My plan was just to write a simple daemon that uses the genetlink API
that Shailabh (IBM) and company wrote and just restart the app if i see
it disappear. 

cheers,
jamal

