From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tiny af_packet.c cleanup
Date: Mon, 15 Sep 2003 15:56:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915155652.3e5e89a0.davem@redhat.com>
References: <20030913055033.GB94744@gaz.sfgoth.com>
	<20030913093559.A23840@electric-eye.fr.zoreil.com>
	<20030913080252.GE94744@gaz.sfgoth.com>
	<20030913110353.B23840@electric-eye.fr.zoreil.com>
	<20030913201559.GI94744@gaz.sfgoth.com>
	<20030914125549.A7790@electric-eye.fr.zoreil.com>
	<20030914112628.GD42531@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20030914112628.GD42531@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 14 Sep 2003 04:26:28 -0700
Mitchell Blank Jr <mitch@sfgoth.com> wrote:

> Francois Romieu wrote:
> > See previously posted patch. Imho the non-trivial part isn't the locking
> > itself but the fact that the first test of sk->sk_filter is done _without_
> > lock.
> 
> OK, that was what I thought was going on.  I figured the short comment (along
> with the likely()) would explain this adequately (i.e. "we're now re-checking
> under lock so we get the authorative answer") but maybe it needs more
> explaination.

When you guys decide on a final patch let me know, the semantic
parts of Mitchell's changes look perfectly fine to me.
