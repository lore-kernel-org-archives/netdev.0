From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPSEC] Find larval SAs by sequence number
Date: Fri, 10 Sep 2004 14:53:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040910145350.26847bec.davem@davemloft.net>
References: <20040909121332.GA31902@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040909121332.GA31902@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 9 Sep 2004 22:13:32 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> When larval states are generated along with ACQUIRE messages, we should
> use the sequence to find the corresponding larval state when creating
> states with ADD_SA or ALLOC_SPI.
> 
> If we don't do that, then it may take down an unrelated larval state
> with the same parameters (think different TCP sessions).  This not only
> leaves behind a larval state that shouldn't be there, it may also cause
> another ACQUIRE message to be sent unnecessarily.

Looks good, applied.
