From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH] net: rxrpc: mark expected switch fall-throughs
Date: Thu, 19 Oct 2017 22:16:56 +0100
Message-ID: <32524.1508447816@warthog.procyon.org.uk>
References: <20171019185016.GA18770@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: dhowells@redhat.com, "David S. Miller" <davem@davemloft.net>,
        linux-afs@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171019185016.GA18770@embeddedor.com>
Content-ID: <32523.1508447816.1@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gustavo A. R. Silva <garsilva@embeddedor.com> wrote:

> +		/* fall through */

All new comments in rxrpc should begin with a capital letter; I'm switching to
this as I modify the lines with comments on.  Fix checkpatch or gcc or
whatever takes -Wimplicit-fallthrough to stop being silly.

> -		/* Fall through */
> -
> +		/* fall through */

No.  Firstly, it should be 'F'; secondly, don't remove the blank line - it's
there for a reason.

> +		/* fall through */

Capital 'F'.

> -
> +		/* fall through */

Don't remove the blank line.  Capital 'F'.

> +			/* fall through */

Capital 'F'.

David
