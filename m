From: Felix Manlunas <felix.manlunas-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4.10-rc3 11/13] net: liquidio: fix build errors when
 linux/phy*.h is removed from net/dsa.h
Date: Wed, 1 Feb 2017 11:07:40 -0800
Message-ID: <20170201190740.GA10128@felix.cavium.com>
References: <20170131191704.GA8281@n2100.armlinux.org.uk>
 <E1cYdxX-0000X5-Hz@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>, <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Derek Chickles <derek.chickles-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Satanand Burla <satananda.burla-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Felix Manlunas <felix.manlunas-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Raghu Vatsavayi <raghu.vatsavayi-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>
To: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <E1cYdxX-0000X5-Hz-eh5Bv4kxaXIk46pC+1QYvQNdhmdF6hFW@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org> wrote on Tue [2017-Jan-31 19:19:19 +0000]:
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:30: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:30: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:30: error: type defaults to 'int' in declaration of 'MODULE_AUTHOR'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:30: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:31: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:31: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:31: error: type defaults to 'int' in declaration of 'MODULE_DESCRIPTION'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:31: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:32: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:32: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:32: error: type defaults to 'int' in declaration of 'MODULE_LICENSE'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:32: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:33: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:33: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:33: error: type defaults to 'int' in declaration of 'MODULE_VERSION'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:33: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:36: error: expected ')' before 'int'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:37: error: expected ')' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:325: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:325: error: type defaults to 'int' in declaration of 'MODULE_DEVICE_TABLE'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:325: warning: parameter names (without types) in function declaration
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:3250: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:3250: error: type defaults to 'int' in declaration of 'module_init'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:3250: warning: parameter names (without types) in function declaration
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:3251: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:3251: error: type defaults to 'int' in declaration of 'module_exit'
> drivers/net/ethernet/cavium/liquidio/lio_vf_main.c:3251: warning: parameter names (without types) in function declaration
> drivers/net/ethernet/cavium/liquidio/lio_main.c:36: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:36: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:36: error: type defaults to 'int' in declaration of 'MODULE_AUTHOR'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:36: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:37: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:37: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:37: error: type defaults to 'int' in declaration of 'MODULE_DESCRIPTION'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:37: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:38: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:38: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:38: error: type defaults to 'int' in declaration of 'MODULE_LICENSE'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:38: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:39: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:39: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:39: error: type defaults to 'int' in declaration of 'MODULE_VERSION'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:39: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:40: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:40: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:40: error: type defaults to 'int' in declaration of 'MODULE_FIRMWARE'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:40: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:41: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:41: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:41: error: type defaults to 'int' in declaration of 'MODULE_FIRMWARE'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:41: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:42: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:42: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:42: error: type defaults to 'int' in declaration of 'MODULE_FIRMWARE'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:42: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:43: error: expected declaration specifiers or '...' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:43: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:43: error: type defaults to 'int' in declaration of 'MODULE_FIRMWARE'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:43: error: function declaration isn't a prototype
> drivers/net/ethernet/cavium/liquidio/lio_main.c:46: error: expected ')' before 'int'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:48: error: expected ')' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:53: error: expected ')' before 'int'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:54: error: expected ')' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:57: error: expected ')' before 'sizeof'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:58: error: expected ')' before string constant
> drivers/net/ethernet/cavium/liquidio/lio_main.c:498: warning: data definitionhas no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:498: error: type defaults to 'int' in declaration of 'MODULE_DEVICE_TABLE'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:498: warning: parameter names (without types) in function declaration
> drivers/net/ethernet/cavium/liquidio/lio_main.c: In function 'octeon_recv_vf_drv_notice':
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4393: error: implicit declaration of function 'try_module_get'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4400: error: implicit declaration of function 'module_put'
> drivers/net/ethernet/cavium/liquidio/lio_main.c: At top level:
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4670: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4670: error: type defaults to 'int' in declaration of 'module_init'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4670: warning: parameter names (without types) in function declaration
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4671: warning: data definition has no type or storage class
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4671: error: type defaults to 'int' in declaration of 'module_exit'
> drivers/net/ethernet/cavium/liquidio/lio_main.c:4671: warning: parameter names (without types) in function declaration
> 
> Add linux/module.h to both these files.
> 
> drivers/net/ethernet/cavium/liquidio/octeon_console.c:40:31: error: expected ')' before 'int'
> drivers/net/ethernet/cavium/liquidio/octeon_console.c:42:4: error: expected ')' before string constant
> 
> Add linux/moduleparam.h to this file.
> 
> Signed-off-by: Russell King <rmk+kernel-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>

Acked-by: Felix Manlunas <felix.manlunas-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

Thank you.
