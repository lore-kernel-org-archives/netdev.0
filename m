From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPV4 route cache /proc interface cleanup
Date: Sun, 24 Aug 2003 04:16:32 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030824041632.705d2b96.davem@redhat.com>
References: <20030821163019.66cfe65c.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20030821163019.66cfe65c.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 21 Aug 2003 16:30:19 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> This patch to 2.6.0-test3 uses seq_file for /proc/net/rt_cache_stat
> Someone else already did the hard one /proc/net/rt_cache
> 
> Couple of other little nits:
> * use proc_net_fops_create to setup
> * collapse two_line setup functions into the init routine
> * proc_exit routine was never called and can go. 
> * cleaner to refer to proc_net as base rather than net/rt_acct

Applied, thanks Stephen.
