From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] sis900 printk and stack usage audit
Date: Sat, 11 Dec 2004 14:06:21 -0500
Message-ID: <41BB452D.5040507@pobox.com>
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
> Removed double printing of version string in module_init and in sis900_probe

> @@ -390,13 +390,6 @@
>  	u8 revision;
>  	char *card_name = card_names[pci_id->driver_data];
>  
> -/* when built into the kernel, we only print version if device is found */
> -#ifndef MODULE
> -	static int printed_version;
> -	if (!printed_version++)
> -		printk(version);
> -#endif
> -
>  	/* setup various bits in PCI command register */
>  	ret = pci_enable_device(pci_dev);
>  	if(ret) return ret;

There is no double-printing.  One is #ifndef MODULE, one is #ifdef MODULE.

Did you read the comment included in the code you deleted???

	Jeff
