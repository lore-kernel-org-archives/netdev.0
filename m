From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] sis900 printk and stack usage audit
Date: Sat, 11 Dec 2004 14:04:08 -0500
Message-ID: <41BB44A8.7000906@pobox.com>
References: <20041208104721.GA31707@picchio.gall.it> <20041208110156.GB31707@picchio.gall.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Venzano <webvenza@libero.it>
In-Reply-To: <20041208110156.GB31707@picchio.gall.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Daniele Venzano wrote:
> Audit of current printk() calls
> Changed debug levels to 0,1,2,3 as follows:
>  0 No debug
>  1 load/probe/unload/suspend/resume stuff
>  2 rx/tx errors
>  3 rx/tx packets and every interrupt are logged (very verbose)
> Debug levels are incremental
> Removed double printing of version string in module_init and in sis900_probe
> Made the sis900_debug parameter modifiable at runtime

Debug levels are standardized, please follow the standard.

All messages are bitmapped.  See NETIF_MSG_* and netif_msg_* in 
include/linux/netdevice.h.

Given the standard 'debug' module parameter, which takes a value from 
0-N (where N==10 or so), the driver uses netif_msg_init() to construct 
the bitmap of messages to be enabled.

	Jeff
