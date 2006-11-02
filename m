From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Big Endian PCI driver
Date: Wed, 1 Nov 2006 21:15:58 -0800
Message-ID: <20061101211558.3da6fccd@localhost.localdomain>
References: <B2EAB41A1AF603458C6A01E3CC809C44027F009F@dbde01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:58076 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751063AbWKBFQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 00:16:21 -0500
To: "Patel, Shalin" <shalinip@ti.com>
In-Reply-To: <B2EAB41A1AF603458C6A01E3CC809C44027F009F@dbde01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2 Nov 2006 10:37:20 +0530
"Patel, Shalin" <shalinip@ti.com> wrote:

> 
> Hi, 
> 
> I am trying to run PCI based Ethernet card (RTL 8139) on a big endian
> host. 
> 
> The pci controller that I have does not have any mechanism for swapping
> the Big Endian data to Little Endian. While running the 8139too.c driver
> I see that the data generated on the line is Endian swapped. 
> 
> In the data sheet of RTL 8139 I could not find any BSWAP bit neither the
> 8139too.c driver does any swapping of data while transmitting or
> receiving. However, if I change the driver to swap data before
> transmitting and after receiving I am able to get it working.
> 
> Does the RTL 8139 driver in 2.6.10 support Big Endian? Is there any
> other Ethernet card driver which supports big endian host (with a PCI
> controller which does not support byte swapping)?
> 
> Thanks,
> Shalin Patel

Skge does the byte swapping in hardware on the card.
Sky2 it was easier to do the byte swapping in software. It isn't hard
to do it in software.
