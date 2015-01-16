From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Fri, 16 Jan 2015 12:03:24 +0100
Message-ID: <1796122.bgT3lt9UAo@storm>
References: <1709726.jUgUSQI9sl@pikkukde.a.i2n> <74814478.Xs0dcijNdd@storm> <20150116105012.GA10655@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:33758 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbbAPLD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 06:03:28 -0500
In-Reply-To: <20150116105012.GA10655@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, 16. January 2015 21:50:13 Herbert Xu wrote:
> On Fri, Jan 16, 2015 at 11:45:44AM +0100, Thomas Jarosch wrote:
> > For backporting to -stable: Kernel 3.14 lacks tcp_tso_autosize().
> > So I've borrowed that from 3.19-rc4+ and also added the max_segs
> > variable.
> > The final and tested code looks like this:
> You don't need tcp_tso_autosize.  Instead of testing max_segs just
> test sk->sk_gso_max_segs.

splendid, even better. tcpdump looks good, too. Thanks!

Thomas
