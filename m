From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] simplify netdev_sysfs_xxx if SYSFS is not configured
Date: Sat, 29 May 2004 12:42:10 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040529124210.2eb8e7c7.davem@redhat.com>
References: <20040528110332.2206b9ac@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040528110332.2206b9ac@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 May 2004 11:03:32 -0700
Stephen Hemminger <shemminger@osdl.org> wrote:

> Don't need all the network sysfs code if CONFIG_SYSFS is not enabled.
> Also:
> 	* netdev_sysfs_unregister is declaration mismatch
> 	* if netdev_sysfs_register fails print a warning.
> 	  Need to still mark it as registered so the unregister_netdevice works,
> 	  but we will probably end up leaking memory in that case.

Applied, thanks.
