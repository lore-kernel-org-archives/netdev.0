From: jamal <hadi@cyberus.ca>
Subject: Re: [IPSEC]: searching  SAD without assumming L3 details
Date: Wed, 06 Sep 2006 08:30:30 -0400
Message-ID: <1157545831.5039.48.camel@jzny2>
References: <1157204582.5197.4.camel@jzny2>
	 <20060905233823.GA9217@gondor.apana.org.au>
	 <1157541639.5039.28.camel@jzny2>
	 <20060906112644.GA22930@gondor.apana.org.au>
	 <1157544895.5039.33.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:64913 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750795AbWIFMaf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Sep 2006 08:30:35 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GKwY8-0007k1-Vb
	for netdev@vger.kernel.org; Wed, 06 Sep 2006 08:30:37 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1157544895.5039.33.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-09 at 08:14 -0400, jamal wrote:
> maybe thats what you meant by "slow path"?

Never mind what i said above;-> what is needed to have replay protection
is calling the IPSEC fast path. The xfrm state is looked up during the
pktgen fast still because flows are created as needed on the fly. You
could argue that we need to change the architecture of pktgen so it
creates all flows first, but that is a huge change.
If i can read your mind correctly (;->)you may be thinking of splitting
xfrm_state_find() into two pieces: a slow path lookup which perhaps
involves the manager and a fast path which looks up just the SAD?
Note, theres still a lot of clunky stuff like policies and templates and
flowis etc that i dont need.

cheers,
jamal

