From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH]: Remove backlog accounting from TBF, pass limit to the
 default inner bfifo qdisc only
Date: Wed, 24 Dec 2003 19:22:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031224192234.0066016b.davem@redhat.com>
References: <3FE98BE9.2000708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <3FE98BE9.2000708@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 24 Dec 2003 13:51:53 +0100
Patrick McHardy <kaber@trash.net> wrote:

> when TBF was made classful, backlog accounting was kept inside
> TBF for reasons I don't understand. When used with SFQ as inner
> qdisc, TBF can not know the exact backlog once SFQ returned
> NET_CMIT_CN. An underestimate leads to backlog becoming negative
> when the queue drains, it stops accepting packets then.
 ...
> This patch removes backlog accounting from TBF, the limit
> parameter is just passed to the default inner bfifo, once it
> is replaced limit is not effective anymore.

Applied to both 2.4.x and 2.6.x, thanks Patrick.
