From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] wandev_show single_open confusion
Date: Fri, 20 Feb 2004 09:41:21 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040220094121.7159df9e.davem@redhat.com>
References: <20040219112705.05416945@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040219112705.05416945@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Feb 2004 11:27:05 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> Fix single_open interface confusion in wanrouter.  The argument passed
> to single_open gets passed through via seq->private; not the void * argument
> as assumed by this code.

Obviously correct, applied.
