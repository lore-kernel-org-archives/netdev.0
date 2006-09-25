From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Is TCP over IPsec broken in 2.6.18?
Date: Mon, 25 Sep 2006 21:27:54 +1000
Message-ID: <20060925112754.GA18228@gondor.apana.org.au>
References: <Pine.LNX.4.64.0609241029410.14827@d.namei> <E1GRdnS-0003kd-00@gondolin.me.apana.org.au> <20060925103836.GA13966@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Morris <jmorris@namei.org>, kaber@trash.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54281 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751364AbWIYL2M
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Sep 2006 07:28:12 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060925103836.GA13966@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2006 at 02:38:36PM +0400, Evgeniy Polyakov wrote:
> 
> I ran two times the same 'telnet 192.168.4.79 22' and got unencrypted
> packets and very long timeout. After some magic initial process things
> started to work as expected - only ESP encrypted packets can be found in
> tcpdump, until next connection is started, which becames to work not
> correctly and then again starts to work as expected.

Perhaps something's screwed up with the policies.  Unfortunately
the racoon logs draw a blank around the interesting interval as
shown by the tcpdump.

Please run ip x p once every second and the post what it shows
before, during and after the period when unecrypted packets show
up on the wire.

You only have to do it on the 79 machine since it's the one sending
unencrypted data.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
