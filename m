From: "David S. Miller" <davem@redhat.com>
Subject: Re: dev/core/net_sysfs.c: missing release() function in net_class
Date: Tue, 19 Aug 2003 08:36:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819083621.2ae4abc8.davem@redhat.com>
References: <Pine.LNX.4.44.0308191500050.26041-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, greg@kroah.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0308191500050.26041-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003 15:47:03 +0300 (EEST)
Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:

> lately I've been getting a nasty looking warning from class_dev_release()
> in drivers/base/class.c when I unregister my ip6_tunnel devices.

This is fixed in current sources after recent changes
done by Stephen Hemminger.
