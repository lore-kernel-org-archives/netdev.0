From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] network hotplug via class_device/kobject
Date: Sun, 15 Jun 2003 12:45:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030615124519.A11939@electric-eye.fr.zoreil.com>
References: <20030613164119.15209934.shemminger@osdl.org> <20030615.005055.55726223.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030615.005055.55726223.davem@redhat.com>; from davem@redhat.com on Sun, Jun 15, 2003 at 12:50:55AM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@redhat.com> :
[rtnl_lock() and register_netdevice()]
>    Paranoid about some driver doing something like:
>    	rtnl_lock(); register_netdevice(); unregister_netdevice(); rtnl_unlock() BOOM
> 
> These sorts of turds exist at least in two places:
> 
> 1) drivers/net/wan/comx.c
> 2) drivers/net/wan/hdlc_fr.c
> 
> But it is pretty clear that these two drivers have been
> tried by nobody in recent years.  They both call into

It's pretty clear but it's false :o)

> {un,}register_netdevice without the RTNL semaphore held.

There is a maintainer for 2):
GENERIC HDLC DRIVER, N2 AND C101 DRIVERS
P:      Krzysztof Halasa
M:      khc@pm.waw.pl
W:      http://hq.pm.waw.pl/hdlc/
S:      Maintained

--
Ueimor
