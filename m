From: "David S. Miller" <davem@redhat.com>
Subject: Re: Oops at "NET: Registering protocol family 23" at boot with
 2.6.0t9-bk
Date: Sat, 1 Nov 2003 19:44:53 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031101194453.70cb8405.davem@redhat.com>
References: <1067705386.666.1.camel@chevrolet.hybel>
	<20031101133601.7cf12497.akpm@osdl.org>
	<1067723628.643.0.camel@chevrolet.hybel>
	<20031101160350.2f1fe0af.akpm@osdl.org>
	<20031101192926.3c7d516f.davem@redhat.com>
	<20031101195137.0b19784a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: liste@jordet.nu, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20031101195137.0b19784a.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 1 Nov 2003 19:51:37 -0800
Andrew Morton <akpm@osdl.org> wrote:

> "David S. Miller" <davem@redhat.com> wrote:
> >
> > If it's just ptype_all that it needs, why don't we just initialize
> >  that one list head at compile time?
> 
> Pessimism, basically.  I'm sure we could locally fix IRDA, but what
> other bugs has that initcall change introduced?

Okie dokie, I'll likely just revert it in my tree after I look this
issue over a little more.
