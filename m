From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 7/9] 8139cp.c printk fix
Date: Fri, 07 Jul 2006 03:38:21 -0400
Message-ID: <44AE0F6D.80400@garzik.org>
References: <200607070658.k676wQIe030380@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:16341 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750767AbWGGHiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Jul 2006 03:38:24 -0400
To: akpm@osdl.org
In-Reply-To: <200607070658.k676wQIe030380@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Andrew Morton <akpm@osdl.org>
> 
> drivers/net/8139cp.c: In function 'cp_init_one':
> drivers/net/8139cp.c:1919: warning: format '%lx' expects type 'long unsigned int', but argument 4 has type 'resource_size_t'
> drivers/net/8139cp.c:1919: warning: format '%lx' expects type 'long unsigned int', but argument 5 has type 'resource_size_t'
> 
> 
> Signed-off-by: Andrew Morton <akpm@osdl.org>
> ---
> 
>  drivers/net/8139cp.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff -puN drivers/net/8139cp.c~8139cp-printk-fix drivers/net/8139cp.c
> --- a/drivers/net/8139cp.c~8139cp-printk-fix
> +++ a/drivers/net/8139cp.c
> @@ -1916,7 +1916,7 @@ static int cp_init_one (struct pci_dev *
>  	regs = ioremap(pciaddr, CP_REGS_SIZE);
>  	if (!regs) {
>  		rc = -EIO;
> -		dev_err(&pdev->dev, "Cannot map PCI MMIO (%lx@%lx)\n",
> +		dev_err(&pdev->dev, "Cannot map PCI MMIO (%Lx@%Lx)\n",
>  		       (unsigned long long)pci_resource_len(pdev, 1),
>  		       (unsigned long long)pciaddr);

should be %llx if I'm not mistaken...  (looks like a merge screwup on my 
part)


