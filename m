From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Allow nested IPv6 encapsulations on same node
Date: Thu, 28 Aug 2003 00:10:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030828001055.1aa32481.davem@redhat.com>
References: <20030827064514.7c060a64.davem@redhat.com>
	<Pine.LNX.4.44.0308271731140.7839-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308271731140.7839-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Aug 2003 19:42:21 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> In the old days ip6_build_xmit() was the way to go if you wanted
> fragmentation, but now ip6_fragment() _seems_ to be able to handle the
> whole thing without the help of ip6_append_data() & Co.
> 
> I'll have to test this and get back to you!

Another point is that you really don't want to use sockets
here for another reason, you're going to get artificial queueing
limits bacause each tunnel packet gets charged to the socket.
