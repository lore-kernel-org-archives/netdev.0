From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] (1/3) Space.c -- alloc_divert_blk not needed here.
Date: Tue, 23 Sep 2003 11:58:15 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030923115815.72819433.davem@redhat.com>
References: <20030923101116.5c5bea3b.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030923101116.5c5bea3b.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 23 Sep 2003 10:11:16 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> No longer need to alloc_divert_blk in probe process because
> the network probe code now calls register_netdevice which does it
> if necessary.

Nice simplification, applied.
