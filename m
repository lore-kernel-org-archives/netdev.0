From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4138] New: ipsec with racoon in transport mode with esp and ah hangs (problem is in xfrm_state_add)
Date: Tue, 1 Feb 2005 08:11:02 +1100
Message-ID: <20050131211102.GA20323@gondor.apana.org.au>
References: <E1CvZCT-00017g-00@gondolin.me.apana.org.au> <200501311640.16118.au@unterluggauer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Unterluggauer <au@unterluggauer.org>
Content-Disposition: inline
In-Reply-To: <200501311640.16118.au@unterluggauer.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Andreas:

On Mon, Jan 31, 2005 at 03:40:16PM +0000, Andreas Unterluggauer wrote:
>
> 2005-01-31 16:29:58: DEBUG: ===
> 2005-01-31 16:29:58: DEBUG: get pfkey ADD message
> andi: libipsec/pfkey.c, pfkey_check: start (msg->sadb_msg_satype: 3)
> 2005-01-31 16:29:58: DEBUG: andi: in pfkey.c, pk_recvadd: msg->sadb_msg_seq 2, msg->sadb_msg_type: ADD
> 2005-01-31 16:29:58: INFO: IPsec-SA established: ESP/Transport 192.168.2.5->192.168.2.3 spi=103868257(0x630e761)
> 2005-01-31 16:29:58: DEBUG: ===

Does the machine hang at this point in time? If not, then this is
simply a racoon bug.  Although the acquire message carries a policy
with it, it's really only acquiring a single SA.  Therefore, only
the SA being acquired should be added with that sequence number.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
