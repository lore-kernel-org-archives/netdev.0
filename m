From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [bonding][1/3] Synchronizing 2.4-2.6
Date: Wed, 27 Aug 2003 17:32:05 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F4D2355.8010803@pobox.com>
References: <200308272000.39229.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shmulik.hen@intel.com
In-Reply-To: <200308272000.39229.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Shmulik Hen wrote:
> This is set 1 that handles backporting bonding stuff from 2.6 into 2.4 
> while fixing some implementation bugs.
> 
> Applies on 2.4.22.
> 
> patch set can be downloaded from:
> http://osdn.dl.sourceforge.net/sourceforge/bonding/patch_set_1_backport.tar.bz2
> 
> This will update the following files:
> 
> 	Documentation/networking/ifenslave.c
> 	drivers/net/bonding/bonding.h
> 	drivers/net/bonding/bond_main.c
> 	drivers/net/net_init.c
> 	include/linux/list.h
> 	include/linux/netdevice.h
> 
> Description:
> patch 1 - Add list_for_each_entry_safe()

applied


> patch 2 - Export alloc_netdev()

already applied and upstream


> patch 3 - Fix /proc read function

applied


> patch 4 - Put the bond's net_device_stats inside the bond struct

already applied and upstream


> patch 5 - Use a linked list to handle multiple bond devices

applied


> patch 6 - Update versions/contributions in header and bump version

applied... even though a non-described ifenslave.c change snuck into 
this patch.
