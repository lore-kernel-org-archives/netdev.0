From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun.c patch to fix "smp_processor_id() in preemptible code"
Date: Wed, 20 Oct 2004 07:54:01 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041019215401.GA16427@gondor.apana.org.au>
References: <E1CK1e6-0004F3-00@gondolin.me.apana.org.au> <1098222676.23367.18.camel@krustophenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vda@port.imtp.ilyichevsk.odessa.ua,
        Linux Network Development <netdev@oss.sgi.com>,
        linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lee Revell <rlrevell@joe-job.com>
Content-Disposition: inline
In-Reply-To: <1098222676.23367.18.camel@krustophenia.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 19, 2004 at 05:51:17PM -0400, Lee Revell wrote:
> 
> Ok, here is the correct patch.  If this is really just a matter of
> performance, and not required for correctness, disabling preemption is
> broken, right?

No if you're doing this then you should get rid of netif_rx_ni()
altogether.  But before you do that please ask all the people who
call it.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
