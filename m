From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] skbuff more likely/unlikely
Date: Fri, 3 Oct 2003 00:19:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031003001916.570546c4.davem@redhat.com>
References: <20031002102420.6e1cece9.shemminger@osdl.org>
	<20031003023431.GC42593@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20031003023431.GC42593@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2 Oct 2003 19:34:31 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> Stephen Hemminger wrote:
> > A couple more places where we can help by hinting the compiler
> > for 2.6.0-test6.  If we are pulling off header, is is likely there;
> > and skb alloc's succeed in the normal case.
> > 
> > Thought I saw an earlier similar patch, but here is my take on it.
> 
> Yes, my patch from a couple weeks ago does the same thing (but also
> did a lot in skbuff.c)  I haven't had a chance to rediff and test
> after the const parts went in.  Do you want to adopt the rest of the
> changes?

I applied Stephen's patch here, you can post something relative
to that if you like.
