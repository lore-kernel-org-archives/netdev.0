From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH] tiny af_packet.c cleanup
Date: Sun, 14 Sep 2003 04:26:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030914112628.GD42531@gaz.sfgoth.com>
References: <20030913055033.GB94744@gaz.sfgoth.com> <20030913093559.A23840@electric-eye.fr.zoreil.com> <20030913080252.GE94744@gaz.sfgoth.com> <20030913110353.B23840@electric-eye.fr.zoreil.com> <20030913201559.GI94744@gaz.sfgoth.com> <20030914125549.A7790@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20030914125549.A7790@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> See previously posted patch. Imho the non-trivial part isn't the locking
> itself but the fact that the first test of sk->sk_filter is done _without_
> lock.

OK, that was what I thought was going on.  I figured the short comment (along
with the likely()) would explain this adequately (i.e. "we're now re-checking
under lock so we get the authorative answer") but maybe it needs more
explaination.

-Mitch
