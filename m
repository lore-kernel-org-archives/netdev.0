From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] common code for generating tcp_info
Date: Fri, 4 Jun 2004 20:57:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040604205749.11725598.davem@redhat.com>
References: <20040604153749.5d8a13b9@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040604153749.5d8a13b9@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 4 Jun 2004 15:37:49 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> There are two places tcp_diag (netlink) and getsockopt, both with almost
> the same code to generate tcp_info from the current socket state.

Works for me, applied.

Should maybe try to move that tcp_info off the stack at some
point.
