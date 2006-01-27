From: Reuben Farrelly <reuben-lkml@reub.net>
Subject: Re: 2.6.16-rc1-mm3
Date: Sat, 28 Jan 2006 00:47:06 +1300
Message-ID: <43DA083A.4040401@reub.net>
References: <20060124232406.50abccd1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750908AbWA0LrT@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060124232406.50abccd1.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 25/01/2006 8:24 p.m., Andrew Morton wrote:
> http://www.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.16-rc1/2.6.16-rc1-mm3/
> 
> - Dropped the timekeeping patch series due to a complex timesource selection
>   bug.
> 
> - Various fixes and updates.
> 
> 
> 
> Changes since 2.6.16-rc1-mm2:

Just triggered this one, which had a fairly bad effect on connectivity to the box:

i2c /dev entries driver
slab error in kmem_cache_destroy(): cache `ip_conntrack': Can't free all objects
  [<b010412b>] show_trace+0xd/0xf
  [<b01041cc>] dump_stack+0x17/0x19
  [<b0155d04>] kmem_cache_destroy+0x9b/0x1a9
  [<f0ebf701>] ip_conntrack_cleanup+0x5d/0x10e [ip_conntrack]
  [<f0ebe31e>] init_or_cleanup+0x1f8/0x283 [ip_conntrack]
  [<f0ec2c4e>] fini+0xa/0x66 [ip_conntrack]
  [<b0136d06>] sys_delete_module+0x161/0x1fb
  [<b0102b3f>] sysenter_past_esp+0x54/0x75
Removing netfilter NETLINK layer.
[root@tornado log]#

I was just reading IMAP mail at the time, ie same as I'd been doing for an hour 
or two beforehand and not altering config of the box in any way.  I was able to 
log on via console but lost all network connectivity and had to reboot :(

Generic details such as .config is at http://www.reub.net/files/kernel/

reuben
