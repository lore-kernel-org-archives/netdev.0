From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPSEC in 2.6.25 causes stalled connections
Date: Tue, 8 Jul 2008 16:07:42 +0800
Message-ID: <20080708080742.GA25027@gondor.apana.org.au>
References: <20080608010858.GA8877@swan.nt.tuwien.ac.at> <E1K8TuP-0002Qd-00@gondolin.me.apana.org.au> <20080618004544.GA25439@swan.nt.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Zeitlhofer <tzeitlho+lkml@nt.tuwien.ac.at>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755544AbYGHIH4@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080618004544.GA25439@swan.nt.tuwien.ac.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry for the late response.

On Wed, Jun 18, 2008 at 02:45:44AM +0200, Thomas Zeitlhofer wrote:
> 
> src 192.168.69.2 dst 192.168.69.1
>         proto esp spi 0xc885bfdd(3364208605) reqid 3(0x00000003) mode tunnel
>         replay-window 32 seq 0x00000000 flag  (0x00000000)
>         auth hmac(sha1) 0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX (160 bits)
>         enc cbc(aes) 0xXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX (256 bits)
>         sel src 0.0.0.0/0 dst 0.0.0.0/0 uid 0
>         lifetime config:
>           limit: soft (INF)(bytes), hard (INF)(bytes)
>           limit: soft (INF)(packets), hard (INF)(packets)
>           expire add: soft 3056(sec), hard 3600(sec)
>           expire use: soft 0(sec), hard 0(sec)
>         lifetime current:
>           2964393536(bytes), 2063237(packets)
>           add 2008-06-18 01:19:47 use 2008-06-18 01:19:48

Your SA has been marked for expiry at 02:19:47.  So what time
did you take this snapshot? Hmm, we really should make the SA
state available to ip x s so that I don't have to ask :)

What IPsec daemon are you using to manage SA rekeying?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
