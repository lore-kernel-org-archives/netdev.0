From: "David S. Miller" <davem@redhat.com>
Subject: Re: Please route new work through -mm tree?
Date: Wed, 29 Sep 2004 13:19:47 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040929131947.03c3e9e5.davem@redhat.com>
References: <1096481023.8636.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <1096481023.8636.7.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 11:03:43 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> There is lots of stuff going on that has a potential to make things less
> stable. How about routing any future TCP, fib, statistics, stuff through
> Andrew's tree and not directly to Linus. That way we have some buffer
> and can stablize some more. Alternatively, Dave you could publize your
> staging area some more.

I'm not changing how I do things because:

1) Putting the net stuff into -mm makes debugging of networking
   changes harder, as -mm has a ton of experimental stuff in it
   as well.  -mm frequently makes machines unbootable, and particularly
   this is felt on non-x86 platforms such as sparc64 which is where
   I do all of my work.

2) I am more than happy to post the location of my net-2.6 tree
   but last time I used this actively (whilst Linus was away for
   2 weeks) the IBM folks complained that this gave them
   too many trees to work from.

Furthermore, I've never put any change into my tree that I didn't
think was ready for upstream.  When I post something here before
pushing to Linus, that's the chance for folks to test things out.
