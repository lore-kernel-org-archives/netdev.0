From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/5] r8169: auto detect 32-bit slot
Date: Thu, 10 Mar 2005 12:17:03 +0100
Message-ID: <20050310111703.GA29018@electric-eye.fr.zoreil.com>
References: <20050309112925.7f7900ab@dxpl.pdx.osdl.net> <200503091608.59122.jdmason@us.ibm.com> <20050309223943.GB9502@electric-eye.fr.zoreil.com> <200503092214.10348.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200503092214.10348.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> +       if ((sizeof(dma_addr_t) > 4) &&
> +           (RTL_R32(Config2) & (1<<3)) && 
> +           !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {
> 
> For the above, I get 8 0 1 respectively.  So, my adapters fail because of the 
> 64bit slot test.  

Config2 can not be a replacement for "use_dac" then.

> If you like, I can try my stand-alone adapter in a 64bit slot of a ppc64 
> system.

It is not strictly necessary. Config2 ought to identify the 64bit slot at best.

Thanks.

--
Ueimor
