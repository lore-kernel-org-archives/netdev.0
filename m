From: "David S. Miller" <davem@redhat.com>
Subject: Re: Bug#251215: kernel-image-2.6.6-1-k7: pppd locks up, cannot be
 killed, during ppp shutdown
Date: Sat, 29 May 2004 13:11:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529131119.6d7d7f4e.davem@redhat.com>
References: <20040529051736.GA11303@gondor.apana.org.au>
	<E1BU2WC-0003nd-00@gondolin.me.apana.org.au>
	<20040529125153.5f2df6ad.davem@redhat.com>
	<20040529200416.GA16929@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: debian.bugs@kepier.clara.net, 251215@bugs.debian.org, shemminger@osdl.org,
        jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040529200416.GA16929@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 30 May 2004 06:04:16 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Sat, May 29, 2004 at 12:51:53PM -0700, David S. Miller wrote:
> > On Sat, 29 May 2004 22:00:52 +1000
> > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > 
> > > Here is a minimal fix for this problem.
> > 
> > Wouldn't it be easier just to move the "list_empty(&net_todo_list)"
> > check to be inside the net_todo_run_mutex semaphore?
> 
> Yes that should work much better.

Great, that's how I'll fix this bug.
