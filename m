From: Scott Feldman <scofeldm@cisco.com>
Subject: Re: [PATCH -next] enic: fix pci_alloc_consistent argument
Date: Tue, 08 Jun 2010 14:55:27 -0700
Message-ID: <C8340A5F.38161%scofeldm@cisco.com>
References: <20100608100020.7d79e932.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Vasanthy Kolluri <vkolluri@cisco.com>,
	Roopa Prabhu <roprabhu@cisco.co>
To: Randy Dunlap <randy.dunlap@oracle.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:12929 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056Ab0FHVzp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 17:55:45 -0400
In-Reply-To: <20100608100020.7d79e932.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/8/10 10:00 AM, "Randy Dunlap" <randy.dunlap@oracle.com> wrote:

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix build warning on i386 (32-bit) with 32-bit dma_addr_t:
> 
> drivers/net/enic/vnic_dev.c: In function 'vnic_dev_init_prov':
> drivers/net/enic/vnic_dev.c:716: warning: passing argument 3 of
> 'pci_alloc_consistent' from incompatible pointer type
> include/asm-generic/pci-dma-compat.h:16: note: expected 'dma_addr_t *' but
> argument is of type 'u64 *'
> 
> Now builds without warnings on i386 and on x86_64.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> Cc: Scott Feldman <scofeldm@cisco.com>
> Cc: Vasanthy Kolluri <vkolluri@cisco.com>
> Cc: Roopa Prabhu <roprabhu@cisco.com>
> ---
>  drivers/net/enic/vnic_dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Scott Feldman <scofeldm@cisco.com>

