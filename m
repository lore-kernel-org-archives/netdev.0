From: "David S. Miller" <davem@redhat.com>
Subject: Re: [NETLINK] hlist initilization
Date: Thu, 23 Sep 2004 18:16:39 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923181639.754ca876.davem@redhat.com>
References: <415372F4.1010400@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <415372F4.1010400@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 24 Sep 2004 03:05:56 +0200
Pablo Neira <pablo@eurodev.net> wrote:

> This patch adds proper initialization for hlist. It applies to 
> af_netlink.c with the workqueue patch reverted.

nl_table[] is in the BSS and therefore will be
properly zero initialized already.

I took advantage of this same property in the
net/ipv4/fib_hash.c changes.
