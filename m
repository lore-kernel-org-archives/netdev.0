From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: dev/core/net_sysfs.c: missing release() function in net_class
Date: Tue, 19 Aug 2003 15:47:03 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0308191500050.26041-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: greg@kroah.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

lately I've been getting a nasty looking warning from class_dev_release()
in drivers/base/class.c when I unregister my ip6_tunnel devices.

The warning (added by Greg Kroah-Hartman in cset 1.1152.2.7) is apparently
triggered because net_class doesn't have .release set.

Would an empty dummy function be enough for net_class or should the
release function actually do something?

Thanks,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257
