From: "David S. Miller" <davem@redhat.com>
Subject: Re: [IPSEC] Use add_timer instead of mod_timer in find_acq
Date: Tue, 25 May 2004 11:02:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040525110244.6284b806.davem@redhat.com>
References: <20040524115357.GA28827@gondor.apana.org.au>
	<20040525121055.GA15690@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040525121055.GA15690@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 May 2004 22:10:55 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, May 24, 2004 at 09:53:57PM +1000, herbert wrote:
> > 
> > Here is a tiny optimisation to use add_timer instead of mod_timer
> > on the create path in find_acq.
> 
> Here is the same optimisation for the creation path in xfrm_state_find.
> It also fixes the timer so that it actually expires :)

Also applied, thanks.
