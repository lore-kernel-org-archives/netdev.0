From: "David S. Miller" <davem@redhat.com>
Subject: Re: IPv4 and IPv6 stack multi-FIB, scalable in the million of
 entries.
Date: Thu, 8 Apr 2004 11:33:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040408113350.03ef5b5c.davem@redhat.com>
References: <1IJuR-8qH-39@gated-at.bofh.it>
	<m3ptaiwfpq.fsf@averell.firstfloor.org>
	<012201c41d94$cee1b400$0348858e@D4SF2B21>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ak@muc.de, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Mathieu Giguere" <Mathieu.Giguere@ericsson.ca>
In-Reply-To: <012201c41d94$cee1b400$0348858e@D4SF2B21>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 8 Apr 2004 14:10:43 -0400
"Mathieu Giguere" <Mathieu.Giguere@ericsson.ca> wrote:

> The main goal to remove the routing cache is to avoid to have 4096 routes
> limitation

This 4K routes limitation is news to everyone who works on this
code.

When nexthop changes we _MUST_ flush PMTU etc. information because that
could have changed.  If however, such information is locked into the
route itself, it will propagate immediately into the routing cache
entry once recreated.

You seem to be talking about a lot of non-problems, but this may because
you're not providing enough details.
