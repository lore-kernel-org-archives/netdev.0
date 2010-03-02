From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH]xfrm: fix perpetual bundles
Date: Tue, 02 Mar 2010 08:54:30 -0500
Message-ID: <1267538070.21749.27.camel@bigi>
References: <1267017564.3973.790.camel@bigi>
	 <20100302112754.GA1513@gondor.apana.org.au>
	 <1267531905.21749.21.camel@bigi>
	 <20100302125156.GA2420@gondor.apana.org.au>
	 <1267535426.21749.24.camel@bigi>  <20100302134656.GC20508@secunet.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	kaber@trash.net, yoshfuji@linux-ipv6.org, nakam@linux-ipv6.org,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f196.google.com ([209.85.223.196]:52431 "EHLO
	mail-iw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946Ab0CBNyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 08:54:39 -0500
Received: by iwn34 with SMTP id 34so192092iwn.15
        for <netdev@vger.kernel.org>; Tue, 02 Mar 2010 05:54:39 -0800 (PST)
In-Reply-To: <20100302134656.GC20508@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-02 at 14:46 +0100, Steffen Klassert wrote:

> The problem was spotted by 
> commit a33bc5c15154c835aae26f16e6a3a7d9ad4acb45
> xfrm: select sane defaults for xfrm[4|6] gc_thresh
> 
> Before this commit, the xfrm garbage collector started to remove
> stale bundle entries as soon as we reached an amount of 1024
> bundle entries. Now the default value for the gc_thresh is
> based on the main route table hash size, so we can have much more
> bundle entries.

yikes. Ok. Seems this fix needs to go -stable as well then.

> I tried it, works for me too.

Did you try with CONFIG_XFRM_SUB_POLICY=y. Thats the only reason
i said "looks like it might work". If you tried with that, then
I dont need to test and I can add an ACKed-by;-> 

cheers,
jamal

