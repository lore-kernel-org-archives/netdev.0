From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [2.6 patch] net/ipv4/: misc possible cleanups
Date: Mon, 27 Dec 2004 19:15:35 -0800
Message-ID: <20041227191535.5edce690.davem@davemloft.net>
References: <20041215005139.GJ23151@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20041215005139.GJ23151@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2004 01:51:39 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> - remove the following unneeded EXPORT_SYMBOL:
>   - tcp_timer.c: tcp_timer_bug_msg

This one is wrong.  It is needed for the ipv6 module
via the call tcp_ipv6.c makes to tcp_done() which
invokes tcp_clear_xmit_timer() which uses
tcp_timer_bug_msg.
