From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: UDP sockets bound to ANY send answers with wrong src ip address
Date: Fri, 11 Jun 2004 20:34:18 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <E1BYjMY-0002CE-00@gondolin.me.apana.org.au>
References: <200406111230.35481.vda@port.imtp.ilyichevsk.odessa.ua>
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
	linux-net@vger.kernel.org, davem@redhat.com, pekkas@netcore.fi,
	jmorris@redhat.com, linux-kernel@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: vda@port.imtp.ilyichevsk.odessa.ua (Denis Vlasenko)
In-Reply-To: <200406111230.35481.vda@port.imtp.ilyichevsk.odessa.ua>
List-Id: netdev.vger.kernel.org

Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> wrote:
> 
> I looked into sendmsg(). Looks like ther is no way to
> indicate source ip.
> 
> Shall I use some other technique?

IP_PKTINFO works just as well there.  Look at the ip_cmsg_send call
in udp_sendmsg.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
