From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Allow nested IPv6 encapsulations on same node
Date: Wed, 27 Aug 2003 06:45:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827064514.7c060a64.davem@redhat.com>
References: <20030827042036.3a00aca8.davem@redhat.com>
	<Pine.LNX.4.44.0308271441390.7839-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308271441390.7839-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Aug 2003 16:22:38 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> On Wed, 27 Aug 2003, David S. Miller wrote:
> > Why do you need to use sockets?  Just send the packets out normally.
> 
> Well ok, I don't need to use sockets, but I do need to use socks :)

You don't need socks either.

Using sockets is just a waste of memory, and you're only using
them because of an interface problem.  Do you see what I'm trying
to say?
