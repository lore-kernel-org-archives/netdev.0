From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Clean up fib_hash datastructures
Date: Sun, 19 Sep 2004 19:46:42 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040919194642.11213625.davem@davemloft.net>
References: <20040918203319.24004d6e.davem@davemloft.net>
	<1095640781.1047.168.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1095640781.1047.168.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 19 Sep 2004 20:39:43 -0400
jamal <hadi@cyberus.ca> wrote:

> Will look at rest of patch and get back to you. Curious piece like you
> note:
> 
> > Does anyone know what this test:
> > 
> > 		if (!iter->zone->fz_next)
> > 			continue;
> > 
> > in fib_get_first() is doing?  I kept it there
> > but it looks fishy.  
> 
> Yes, it is fishy;-> patch attached. Probably one of the more interesting
> typos i have seen recently

Aha, yes, if you look at the original code before this stuff was
converted to use seq_file, and therefore the 2.4.x copy of this
code, the typo is even more obvious.

Good spotting Jamal.
