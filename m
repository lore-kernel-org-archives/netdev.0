From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 2/3] drivers/net/wireless/prism54/islpci_hotplug: Use
 the DMA_{64, 32}BIT_MASK constants
Date: Mon, 07 Mar 2005 12:24:24 -0500
Message-ID: <422C8E48.9000006@pobox.com>
References: <20050306222355.6686C1ED3D@trashy.coderock.org> <20050307171418.GT3936@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: domen@coderock.org, prism54-private@prism54.org, netdev@oss.sgi.com,
        tklauser@nuerscht.ch
To: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
In-Reply-To: <20050307171418.GT3936@ruslug.rutgers.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> On Sun, Mar 06, 2005 at 11:23:55PM +0100, domen@coderock.org wrote:
> 
>>Use the DMA_{64,32}BIT_MASK constants from dma-mapping.h
>>when calling pci_set_dma_mask() or pci_set_consistent_dma_mask()
>>
>>Signed-off-by: Tobias Klauser <tklauser@nuerscht.ch>
>>Signed-off-by: Domen Puncer <domen@coderock.org>
>>---
>>
>>
>> kj-domen/drivers/net/wireless/prism54/islpci_hotplug.c |    2 +-
>> 1 files changed, 1 insertion(+), 1 deletion(-)
>>
>>diff -puN drivers/net/wireless/prism54/islpci_hotplug.c~dma_mask-drivers_net_wireless_prism54_islpci_hotplug drivers/net/wireless/prism54/islpci_hotplug.c
>>--- kj/drivers/net/wireless/prism54/islpci_hotplug.c~dma_mask-drivers_net_wireless_prism54_islpci_hotplug	2005-03-05 16:12:02.000000000 +0100
>>+++ kj-domen/drivers/net/wireless/prism54/islpci_hotplug.c	2005-03-05 16:12:02.000000000 +0100
>>@@ -125,7 +125,7 @@ prism54_probe(struct pci_dev *pdev, cons
>> 	}
>> 
>> 	/* enable PCI DMA */
>>-	if (pci_set_dma_mask(pdev, 0xffffffff)) {
>>+	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
> 
> 
> Is this 2.4 backward compatible? If not we'll have to add to 2.4 compat
> file on prism54.

Not compatible, but it is preferred to patch the file and add that 
definition to a compat header.

For pci_module_init(), it is preferred to keep pci_module_init() rather 
than adding compat gunk.

	Jeff
