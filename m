From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV6 debug printk error and missing release in error
 path
Date: Mon, 22 Dec 2003 00:16:03 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031222001603.2830ff0d.davem@redhat.com>
References: <20031219132431.37980ccb.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031219132431.37980ccb.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 19 Dec 2003 13:24:31 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> A couple of small fixes for IPV6 network discovery:
>   * A NPRINTK2 in ndisc_parse_options would not compile if ND_DEBUG level was up to 3
>   * missing dst_release in ndisc_send_rs error path if skb_alloc fails.

Applied, thanks Stephen.
