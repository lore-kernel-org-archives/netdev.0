From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 8/8 2.5] e1000 - White space changes, driver version number
 update and others
Date: Fri, 17 Sep 2004 11:00:46 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <414AFC1E.5010204@pobox.com>
References: <Pine.LNX.4.44.0409170239280.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <Pine.LNX.4.44.0409170239280.15233-100000@isotope.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> @@ -386,10 +386,10 @@ e1000_probe(struct pci_dev *pdev,
>  	if((err = pci_enable_device(pdev)))
>  		return err;
>  
> -	if(!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK))) {
> +	if(!(err = pci_set_dma_mask(pdev, PCI_DMA_64BIT))) {
>  		pci_using_dac = 1;
>  	} else {
> -		if((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK))) {
> +		if((err = pci_set_dma_mask(pdev, PCI_DMA_32BIT))) {
>  			E1000_ERR("No usable DMA configuration, aborting\n");
>  			return err;
>  		}
> 
> 
> 
> 

Applied patches 1-2 and patches 4-7 to 2.6.x.

Patch #8 (quoted above) is rejected because DMA_..BIT_MASK is the 
preferred method for 2.6.x kernels.  The above patch is a regression.

Patch #3 is rejected because of an email problem:
> bk import -tpatch -CR -ye1000 -  Fix MODULE_PARM, module_param and /tmp/patch25004 .
> patch: **** malformed patch at line 62:         }
