From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] tcp_send_skb code pruning
Date: Tue, 27 Apr 2004 20:29:57 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040427202957.058da584.davem@redhat.com>
References: <20040427160428.0196fcf3@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040427160428.0196fcf3@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 27 Apr 2004 16:04:28 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> The function tcp_send_skb is only called from tcp_fin, and is always called
> with force_queue=1.  Therefore, it no longer needs to be global and the code
> to send right now can be removed.  Because it always queues, change the
> name as well, and fix up the comment.

Nice cleanup, applied.
