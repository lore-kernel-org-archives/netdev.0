From: Greg KH <greg@kroah.com>
Subject: Re: [KJ] [PATCH 9/18] drivers/net/ remove pci_find_{device, subsys}
Date: Mon, 14 Feb 2005 10:46:15 -0800
Message-ID: <20050214184613.GP7815@kroah.com>
References: <200502141125.25185.amitg@calsoftinc.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5488872609210631=="
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, gud@eth.net,
   kernel-janitors@lists.osdl.org
To: Amit Gud <amitg@calsoftinc.com>
In-Reply-To: <200502141125.25185.amitg@calsoftinc.com>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============5488872609210631==
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Feb 14, 2005 at 11:25:23AM +0530, Amit Gud wrote:
> diff -uprN orig/drivers/net/gt96100eth.c linux-2.6.11-rc3/drivers/net/gt96100eth.c
> --- orig/drivers/net/gt96100eth.c	2005-02-11 15:19:48.000000000 +0530
> +++ linux-2.6.11-rc3/drivers/net/gt96100eth.c	2005-02-14 02:07:09.000000000 +0530
> @@ -615,9 +615,9 @@ static int gt96100_init_module(void)
>  	/*
>  	 * Stupid probe because this really isn't a PCI device
>  	 */
> -	if (!(pci = pci_find_device(PCI_VENDOR_ID_MARVELL,
> +	if (!(pci = pci_get_device(PCI_VENDOR_ID_MARVELL,
>  	                            PCI_DEVICE_ID_MARVELL_GT96100, NULL)) &&
> -	    !(pci = pci_find_device(PCI_VENDOR_ID_MARVELL,
> +	    !(pci = pci_get_device(PCI_VENDOR_ID_MARVELL,
>  		                    PCI_DEVICE_ID_MARVELL_GT96100A, NULL))) {
>  		printk(KERN_ERR __FILE__ ": GT96100 not found!\n");
>  		return -ENODEV;

This (and many other parts of this patch) are incorrect.  Please do not
apply.

thanks,

greg k-h

--===============5488872609210631==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============5488872609210631==--
