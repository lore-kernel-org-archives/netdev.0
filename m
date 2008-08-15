From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for	iptables nat routing
Date: Fri, 15 Aug 2008 14:44:26 +1000
Message-ID: <E1KTrAo-0001YG-00@gondolin.me.apana.org.au>
References: <1218726484.23510.20.camel@2710p.home>
Cc: kaber@trash.net, davem@davemloft.net, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: alex.williamson@hp.com (Alex Williamson)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35523 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750791AbYHOEoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 00:44:38 -0400
In-Reply-To: <1218726484.23510.20.camel@2710p.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Williamson <alex.williamson@hp.com> wrote:
> 
> Attached, let me know if you want more options, this is just -vv -n.
> The NAT'ing system is at 10.0.2.15 and the ssh tunnel target is
> 192.168.1.60.  Thanks,

Right, the underlying TCP connection is going well, but the NATed
connection is getting checksum errors.  Please send us the raw
packet dump on lo (tcpdump -s 1600 -w file) so we can see what's
wrong.

Actually, I think know what's going on but a raw packet dump should
confirm whether we're getting a partial checksum.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
