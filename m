From: "David S. Miller" <davem@redhat.com>
Subject: Re: Check connect address in NETLINK
Date: Mon, 28 Jun 2004 17:30:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040628173039.19e61bb4.davem@redhat.com>
References: <20040628231439.GA3021@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040628231439.GA3021@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 29 Jun 2004 09:14:39 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> The solution seems simple.  We already have a connect(2) call for
> NETLINK sockets.  So why don't we check the connected address of
> the destination socket against the address of the sender before
> putting the packet on the queue?
> 
> Any comments before I go ahead and code it?

This really won't break any existing legitimate cases?
Are you sure?
