From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp FRTO: in-order-only "TCP proxy" fragility
 workaround
Date: Mon, 11 Aug 2008 14:41:03 -0700 (PDT)
Message-ID: <20080811.144103.192682287.davem@davemloft.net>
References: <20080806155306.72039010@tux>
	<Pine.LNX.4.64.0808071422360.4551@wrl-59.cs.helsinki.fi>
	<20080808004231.10dd7356.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, fragabr@gmail.com,
	thomas.jarosch@intra2net.com, netdev@vger.kernel.org,
	kaber@trash.net, sr@securenet.de, netfilter-devel@vger.kernel.org,
	kadlec@blackhole.kfki.hu
To: billfink@mindspring.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20080808004231.10dd7356.billfink@mindspring.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bill Fink <billfink@mindspring.com>
Date: Fri, 8 Aug 2008 00:42:31 -0400

> Since you suspect the problem is being caused by a broken middlebox,
> would it perhaps be a better approach to add a per-route option to
> allow disabling of FRTO for the given destination.  This would be
> similar to Stephen Hemminger's fix for broken middleboxes that don't
> handle window scaling properly.  It seems this would be better than
> modifying FRTO behavior for everyone else that is being compliant.

This is the kind of direction I'm leaning towards as well.

The behavior of these middleboxes borders on unbelievable.  And there
comes a point where catering to these various busted boxes stops to
make sense.  At some point we have to say "sorry, someone has to get
that box fixed."

You can't reorder packets like that, on purpose, and not expect some
new, yet reasonable, TCP algorithm to fall flat on it's face.
