From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/4) Support for lots of netdev's -- dev_base move
Date: Fri, 6 Feb 2004 13:39:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206133926.29344238.davem@redhat.com>
References: <20040206100310.21ebd1da.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040206100310.21ebd1da.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Feb 2004 10:03:10 -0800
Stephen Hemminger <shemminger@osdl.org> wrote:

> The first patch moves the device list and locks from drivers/net/Space.c
> to net/core/dev.c. The list used to be in Space.c because we initialized it
> in 2.4, but now it makes more sense to put it over with the management
> routines.

Applied.

I hope we can eventually mark these two things static somehow.  I know
there's a lot needed to do that, so not now just eventually.

Thanks Stephen.
