From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [Openswan Users] 	DPD Problem - message from kernel malformed:
 unknown address family
Date: Wed, 20 Oct 2004 16:08:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041020160849.085bb075.davem@davemloft.net>
References: <417675C6.3040704@gmx.ch>
	<E1CKOXc-0002Kq-00@gondolin.me.apana.org.au>
	<20041020230929.GA9390@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mailing-lists@gmx.ch, users@openswan.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041020230929.GA9390@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Oct 2004 09:09:29 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Thu, Oct 21, 2004 at 08:02:44AM +1000, Herbert Xu wrote:
> > 
> > Looks like nobody has tested shunt routes for a while.
> > 
> > It's a kernel bug.  We're not setting the family field in the selector.
> > This patch fixes it.
> 
> Dave, please scratch that patch.  The family is already being set
> elsewhere.  Until we have real cross-family transforms this won't
> be needed.

So why is the unknown address error occuring for this case?
Is it just a case we don't need to worry about at this time?
