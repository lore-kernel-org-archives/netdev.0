From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] resolve probe difference
Date: Mon, 13 Oct 2003 12:45:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031013124545.6939cb61.davem@redhat.com>
References: <20031013114852.74b547d0.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031013114852.74b547d0.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Oct 2003 11:48:52 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> In the change to get rid of the list of ISA devices to programmatic probing
> of old devices, a behaviour change was introduced which might cause problems.
> 
> Before, it was possible to specify a parameter on the boot line for a second
> device and skip the first, as in:
> 	netdev=4,0x280,0,0,eth1
> Well, now we stop after eth0 if we don't find it..
> Somebody, might depend on the old behaviour, so this patch restores it..

Looks good, applied.

Thanks a lot Stephen.
