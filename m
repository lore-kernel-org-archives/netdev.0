From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] add receive DRS info
Date: Mon, 7 Jun 2004 15:27:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040607152700.7f9252a1.davem@redhat.com>
References: <20040604153749.5d8a13b9@dell_ss3.pdx.osdl.net>
	<20040604205749.11725598.davem@redhat.com>
	<20040607100744.1b67baa2@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040607100744.1b67baa2@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 7 Jun 2004 10:07:44 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Add receiver feedback information to the tcp_info structure to allow
> looking at receive dynamic right sizing with 'ss' command.
> 
> This increases the size of the structure, but since both getsockopt() and netlink
> interface pass length in request; it retains compatibility with older versions.

Right, applied.  Thanks Stephen.
