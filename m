From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6 PATCH] ipchains masquerade must select maddr correctly
Date: Tue, 2 Dec 2003 16:22:08 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031202162208.04629dab.davem@redhat.com>
References: <Pine.LNX.4.44.0312030150080.1237-200000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, laforge@gnumonks.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312030150080.1237-200000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Dec 2003 01:55:28 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> 	The attached patch fixes ipchains masquerade to use
> correctly the routing. This bug-to-bug compatibility with 2.2
> is not valid from long time. Also, a missing unlock is added.

Slow down.

I don't think it's always desirable to specify a specific TOS when
we're working with an input packet.  In fact, what you're doing all
over the tree is going to cause the routing cache size to explode in
some very real usage.
