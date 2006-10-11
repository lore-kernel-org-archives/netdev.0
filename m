From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [TCP]: TCP MD5 Signature Option (RFC2385) Support.
Date: Tue, 10 Oct 2006 19:43:18 -0700 (PDT)
Message-ID: <20061010.194318.82102936.davem@davemloft.net>
References: <20061011.113900.08679683.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26305
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932414AbWJKCnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 22:43:15 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20061011.113900.08679683.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Wed, 11 Oct 2006 11:39:00 +0900 (JST)

>     [TCP]: Use TCPOLEN_TSTAMP_ALIGNED macro instead of magic number.
>     [NET]: Use hton{l,s}() for non-initializers.
>     [NET]: Use typesafe inet_twsk() inline function instead of cast.
>     [NET]: Introduce protocol-specific destructor for time-wait sockets.

All 4 patches applied.

>     [TCP]: MD5 Signature Option (RFC2385) support.

And this one we can let sit for a while for review.  We can
put it into net-2.6.20 once it is ready and I open up that
tree.

I do not intend to make a net-2.6.20 tree for a few weeks so
people will concentrate on bug fixing for 2.6.19, so we have
a lot of time for this :-)
