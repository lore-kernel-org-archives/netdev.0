From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Change MAC without bringing interface down
Date: Mon, 18 Aug 2003 07:20:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818072044.5a41ced5.davem@redhat.com>
References: <20030818091312.GA4889@lapdog>
	<20030818041911.358c3437.davem@redhat.com>
	<20030818142455.GA1793@lapdog>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommi Virtanen <tv@debian.org>
In-Reply-To: <20030818142455.GA1793@lapdog>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 17:24:55 +0300
Tommi Virtanen <tv@debian.org> wrote:

> > I would suggest to fix this by instead flushing the hh
> > entries (just like neigh_destroy() does).
> 
> 	This may be a dumb question, but how do I do that?
> 
> 	If I set them to neigh_blackhole, like neigh_destroy() does,
> 	e.g. already running gets -ENETDOWN. That's now true and it's
> 	not nice. I'm having trouble seeing how to "disable" the
> 	neighbour entry, so it won't be used again.

You have to also remove them from the list, like neigh_destroy()
does, are you doing that as well?
