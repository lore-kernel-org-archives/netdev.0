From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix BUG in tg3_tx
Date: Mon, 24 May 2004 00:40:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040524004045.58b3eb44.davem@redhat.com>
References: <20040524072657.GC27177@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040524072657.GC27177@sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 24 May 2004 17:26:58 +1000
Greg Banks <gnb@sgi.com> wrote:

> The tg3 transmit code assumes that tg3_tx() will never have to clean
> up part of an skb queued for transmit.  This assumption is wrong;

Greg, perhaps my reading of the tg3 chip docs is different
from yours.  The hardware is NEVER supposed to do this.

Or is there an errata in some chip versions?

I've never triggered that BUG() assertion on any of my
hardware, ever.
