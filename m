From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix build problem with IPV6
Date: Sat, 16 Aug 2003 07:50:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030816075046.752e58cc.davem@redhat.com>
References: <20030815140740.388a79c4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030815140740.388a79c4.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 15 Aug 2003 14:07:40 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> IPV6 won't build in current 2.6.0-test3 tree unless CONFIG_XFRM is defined
> because of reference to xfrm6_fini.

Applied, thanks Stephen.

> The linux way to fix this would be to make the functions
> stub's in the include file, but that isn't how IPV6 does it now
> for other xfrm functions.

If someone wants to clean house in this area, I'll happily
take patches doing that. :)
