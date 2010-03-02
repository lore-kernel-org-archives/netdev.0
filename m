From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH]xfrm: fix perpetual bundles
Date: Tue, 02 Mar 2010 08:10:26 -0500
Message-ID: <1267535426.21749.24.camel@bigi>
References: <1267017564.3973.790.camel@bigi>
	 <20100302112754.GA1513@gondor.apana.org.au>
	 <1267531905.21749.21.camel@bigi>
	 <20100302125156.GA2420@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kaber@trash.net, yoshfuji@linux-ipv6.org,
	nakam@linux-ipv6.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51210 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123Ab0CBNKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 08:10:35 -0500
Received: by vws9 with SMTP id 9so75674vws.19
        for <netdev@vger.kernel.org>; Tue, 02 Mar 2010 05:10:34 -0800 (PST)
In-Reply-To: <20100302125156.GA2420@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-03-02 at 20:51 +0800, Herbert Xu wrote:

> Heh, you've just discovered a bug that I carefully planted back
> in 2007, while merging the v4/v6 policy code :)

;-> I am suprised it hasnt been noticed sooner given it accumulates
memory on a per-packet basis.

> It is a clear merging error, where *fl became rt->fl which is
> totally different.  So please try this patch:
> 

Looks like it would work.
I dont have time right now - but will by either tonight or tomorrow
evening. Steffen, if you have time - please go ahead and try it out
as well.

cheers,
jamal

