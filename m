From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: (5/5) Allow IPv6 tunnels without own IPv6 address
Date: Mon, 1 Sep 2003 03:51:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030901035134.2585aa79.davem@redhat.com>
References: <20030901020340.5a128836.davem@redhat.com>
	<Pine.LNX.4.44.0309011345141.17318-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0309011345141.17318-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 1 Sep 2003 13:48:44 +0300 (EEST)
Pekka Savola <pekkas@netcore.fi> wrote:

> Well, link-local addresses are used e.g. by routing protocols and such, so 
> having one is probably rather important..

Ok.

> FWIW, on FreeBSD platform they take the link-local address of the first
> physical interface, and give the exact same link-local address on all of
> the tunnels, disambiuating them with the scope identifier.  Seems like an
> OK appaorach too, and guarantees (to the degree of unique MAC addresses)  
> that the addresses of the endpoints do not clash.

Interesting approach...  I'm not particularly picky about how this
uniqueness issue is solved.
