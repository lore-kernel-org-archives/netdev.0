From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: dev->destructor
Date: Thu, 1 May 2003 14:28:22 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030501172822.GE3387@conectiva.com.br>
References: <20030501.000058.39187964.davem@redhat.com> <20030501120815.25BE22C155@lists.samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, kuznet@ms2.inr.ac.ru,
   shemminger@osdl.org, netdev@oss.sgi.com,
   Werner Almesberger <wa@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
Content-Disposition: inline
In-Reply-To: <20030501120815.25BE22C155@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Thu, May 01, 2003 at 10:01:19PM +1000, Rusty Russell escreveu:
 
> But before we redesign module architecture from scratch, let's look at
> a solution with what we do have (assuming Linus takes my damn
> __module_get() patch some day, see below).

Linus took the __module_get patch, I even used it in redesigning the way
struct sock and struct socket are handled in response to Max Krasnyansky
alternative patches
 
> There are 70 calls to dev_hold() in the kernel.  The vast majority of
> them already have a reference, they just want another one: dev_hold()
> can do __module_get().

yes
 
> There are a few *sources* of devices: dev_get, dev_get_by*.  These
> should check and fail, using "try_dev_hold()" or something.
> Unfortunately auditing all the __dev_get_by* is quite a task, since
> it's used very widely (and I think, sometime erroneously).
> 
> Completely untested patch below other patch.
> 
> I need more time to digest your proposal in detail, Dave.  Expect
> reply w/in 24 hours.

I'm digesting it as well 8)

- Arnaldo
