From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun.c patch to fix "smp_processor_id() in preemptible code"
Date: Wed, 20 Oct 2004 07:35:54 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CK1e6-0004F3-00@gondolin.me.apana.org.au>
References: <1098210711.2148.69.camel@krustophenia.net>
Cc: vda@port.imtp.ilyichevsk.odessa.ua, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: rlrevell@joe-job.com (Lee Revell)
In-Reply-To: <1098210711.2148.69.camel@krustophenia.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Lee Revell <rlrevell@joe-job.com> wrote:
> 
> I looked at Robert Love's book and I am still unclear on the use of
> do_softirq above.  To reiterate the question:  why does netif_rx_ni have
> to manually flush any pending softirqs on the current proccessor after
> doing the rx?  Is this just a performance hack?

Yes it allows the packet to be processed immediately.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
