From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: register_dev
Date: Mon, 28 Mar 2005 14:56:41 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0503281451090.25430@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

I have a little problem.

I do a register_netdev inside a _init function of a home made qdisc.

2 cases:

1. Modprobe before working with it
 	Everything works ok.
2. the module is not loaded and I let tc trigger module loading
 	tc blocks on modprobe
 	modprobe blocks on register_netdev
 	Very probably that rtnl_sem is taken by netlink in kernel and
 	register_nedev tries to aquire the sem, too.

If I use register_netdevice, seems ok but in case 1, the is no sem 
protection anymore.
How I can resolve this problem?

Thank you!
---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
