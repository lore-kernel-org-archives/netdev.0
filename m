From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPSec Oops when deleting an ip address
Date: Tue, 25 May 2004 11:01:18 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20040525110118.13ef9d88.davem@redhat.com>
References: <20040510134958.13691.qmail@mason.oriente.labs.it>
	<20040521131950.GA20040@gondor.apana.org.au>
	<20040521144346.7887dbf0.davem@redhat.com>
	<20040524114751.GA28571@gondor.apana.org.au>
	<20040525115220.GA15236@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040525115220.GA15236@gondor.apana.org.au>
List-Id: netdev.vger.kernel.org

On Tue, 25 May 2004 21:52:20 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The same bug exists in xfrm_state_find.  This is actually used by
> Openswan.  However, the larval state never actually matures with
> Openswan so it only ever gets deleted by the timer which means that
> the timer crash can't happen :) It becomes a (possible) memory leak
> instead.

Looks good, applied.
