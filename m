From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 07 Apr 2009 09:47:47 -0400
Message-ID: <1239112067.32737.51.camel@dogo.mojatatu.com>
References: <1238701718.5669.26.camel@bender>
	 <20090407072647.GA11480@gondor.apana.org.au>
	 <1239108520.32737.28.camel@dogo.mojatatu.com>
	 <20090407130447.GA14329@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johann Baudy <johann.baudy@gnu-log.net>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:37950 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756732AbZDGNud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 09:50:33 -0400
Received: by rv-out-0506.google.com with SMTP id b25so297372rvf.5
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2009 06:50:31 -0700 (PDT)
In-Reply-To: <20090407130447.GA14329@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-04-07 at 21:04 +0800, Herbert Xu wrote:

> Well through tc ipt actions you can invoke arbitrary netfilter
> targets, including MARK --set-mark.

I thought you were saying this issue can be solved by 
tc/mark but you meant tc/mark is one culprit;->
Solvable by making sure tc/mark is not used in the system
you are running an app using this feature.

But the superset of what Johann wants seems to be a common 
issue: identifying _precisely_ when the skb sent out is done 
with - in his case, so he can use some field to lookup a table.
Other times i have seen people ask for it is for tun/tap 
notification in user space when a packet sent actually went out.

> In fact I've never really liked tc ipt actions since it doesn't
> do any sanity checking on the packet before invoking the target
> while normally netfitler does quite a bit of sanity checking.

more could be done in user space if you really need it.

cheers,
jamal

