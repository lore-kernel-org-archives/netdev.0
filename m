From: Mirko Lindner <mlindner@syskonnect.de>
Subject: Re: [PATCH 2.6.9-rc3] sk98lin - register the driver with hotplug
Date: Fri, 01 Oct 2004 13:59:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <415D46BE.3080904@syskonnect.de>
References: <415C8322.7030005@stud.feec.vutbr.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michal Schmidt <xschmi00@stud.feec.vutbr.cz>
In-Reply-To: <415C8322.7030005@stud.feec.vutbr.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Michal,

thanks for the patch. I'll include the changes into the driver.

Cheers,
Mirko

Michal Schmidt wrote:
> Hello,
> 
> The attached patch allows the sk98lin module to be loaded automatically 
> by hotplug.
> 
> Michal Schmidt
> 
> 
> ------------------------------------------------------------------------
> 
> --- linux-2.6.9-rc3.orig/drivers/net/sk98lin/skge.c	2004-09-30 23:38:44.181252712 +0200
> +++ linux-2.6.9-rc3/drivers/net/sk98lin/skge.c	2004-09-30 21:02:04.000000000 +0200
> @@ -5169,6 +5169,8 @@ static struct pci_device_id skge_pci_tbl
>  	{ 0, }
>  };
>  
> +MODULE_DEVICE_TABLE(pci, skge_pci_tbl);
> +
>  static struct pci_driver skge_driver = {
>  	.name		= "skge",
>  	.id_table	= skge_pci_tbl,
