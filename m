From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [Openswan dev] Re: IPv4 tunneled over IPv6-IPsec?
Date: Sun, 27 Mar 2005 20:05:44 +1000
Message-ID: <E1DFUeO-0001IS-00@gondolin.me.apana.org.au>
References: <DD992FDA2A9E3512996A18A9@[192.168.17.4]>
Cc: dev@openswan.org
To: pb@bieringer.de (Peter Bieringer)
In-Reply-To: <DD992FDA2A9E3512996A18A9@[192.168.17.4]>
Cc: netdev@oss.sgi.com
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@openswan.org>
List-Help: <mailto:dev-request@openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=subscribe>
Sender: dev-bounces@openswan.org
Errors-To: dev-bounces@openswan.org
List-Id: netdev.vger.kernel.org

Peter Bieringer <pb@bieringer.de> wrote:
> 
> I retry to play tunneling IPv4 over IPv6-IPsec. Afair it is still not 
> working (support is missing in 2.6.x kernel), but for startup, I have 
> already a patch for ipsec.conf parsing (pluto already has an option to do 
> this):

The native IPsec stack doesn't support IPv4 over IPv6 or IPv6 over
IPv4 SAs.  It won't be able to do so unless major surgery is done
to the IPsec and IP stack.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
