From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 1/5] r8169: auto detect 32-bit slot
Date: Wed, 9 Mar 2005 22:14:10 -0600
Message-ID: <200503092214.10348.jdmason@us.ibm.com>
References: <20050309112925.7f7900ab@dxpl.pdx.osdl.net> <200503091608.59122.jdmason@us.ibm.com> <20050309223943.GB9502@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@muc.de>, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050309223943.GB9502@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[...]
> The content of the Config2 register could be interesting.

I did a quick test and my 2 adapters (integrated and stand-alone) fail the DAC 
test.

+       if ((sizeof(dma_addr_t) > 4) &&
+           (RTL_R32(Config2) & (1<<3)) && 
+           !pci_set_dma_mask(pdev, DMA_64BIT_MASK)) {

For the above, I get 8 0 1 respectively.  So, my adapters fail because of the 
64bit slot test.  

If you like, I can try my stand-alone adapter in a 64bit slot of a ppc64 
system.
