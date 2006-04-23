From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TCP not retransmitting supposedly lost segment
Date: Sun, 23 Apr 2006 22:27:18 +1000
Message-ID: <20060423122718.GA16504@gondor.apana.org.au>
References: <20060406171926.GA8142@florz.florz.dyndns.org> <20060410010005.GA9282@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:61453 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751395AbWDWM1Y
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Apr 2006 08:27:24 -0400
To: Florian Zumbiehl <florz@gmx.de>
Content-Disposition: inline
In-Reply-To: <20060410010005.GA9282@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 10, 2006 at 01:00:05AM +0000, Florian Zumbiehl wrote:
> 
> meanwhile I gathered some information from /proc/net/tcp6 on this
> problem - in case anyone is interested :-)
> 
> | 1144560959:   8: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:1223 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:1A0B 01 00000000:00000000 02:00097F82 00000000  1000        0 3188619 8 c1409260 89 10 20 2 2
> | 1144560969:   8: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:1223 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:1A0B 01 00000016:00000000 01:00000074 00000004  1000        0 3188619 9 c1409260 1424 10 18 1 2
> | 1144560980:   8: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:1223 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:1A0B 01 00000016:00000000 01:000000FA 00000005  1000        0 3188619 9 c1409260 2848 10 18 1 2
> | 1144560990:   8: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:1223 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx:1A0B 01 00000016:00000000 01:000005F2 00000006  1000        0 3188619 9 c1409260 5696 10 18 1 2

This tells us that the kernel was indeed retransmitting but the
packet didn't make it out of the interface according to your
tcpdump.

Do you have any firewall rules? Any tc rules?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
