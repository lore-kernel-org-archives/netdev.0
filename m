From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Allow nested IPv6 encapsulations on same node
Date: Wed, 27 Aug 2003 04:20:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030827042036.3a00aca8.davem@redhat.com>
References: <Pine.LNX.4.44.0308271413450.7839-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308271413450.7839-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Aug 2003 14:26:42 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> this incremental patch allows nested IPv6 encapsulations on the same node
> by allocating separate sockets for all ip6_tnl devices. Please apply!

If you didn't use sockets to send the packets out, you wouldn't
have this problem to begin with.

Why do you need to use sockets?  Just send the packets out normally.
