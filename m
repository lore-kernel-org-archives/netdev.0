From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH] skbuff more likely/unlikely
Date: Thu, 2 Oct 2003 19:34:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003023431.GC42593@gaz.sfgoth.com>
References: <20031002102420.6e1cece9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20031002102420.6e1cece9.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> A couple more places where we can help by hinting the compiler
> for 2.6.0-test6.  If we are pulling off header, is is likely there;
> and skb alloc's succeed in the normal case.
> 
> Thought I saw an earlier similar patch, but here is my take on it.

Yes, my patch from a couple weeks ago does the same thing (but also
did a lot in skbuff.c)  I haven't had a chance to rediff and test
after the const parts went in.  Do you want to adopt the rest of the
changes?

Original patch:
  http://oss.sgi.com/projects/netdev/archive/2003-09/msg00036.html

-Mitch
