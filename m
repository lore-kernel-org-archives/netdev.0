From: Jagan Teki <jagannadh.teki@gmail.com>
Subject: Re: sblk->status_tag on drivers/net/ethernet/broadcom/tg3.c
Date: Thu, 6 Mar 2014 01:32:54 +0530
Message-ID: <CAD6G_RQ=Zomytu+CAd0Os1ZZokJQiju-LvpABHdRRaQGSVC7FQ@mail.gmail.com>
References: <CAD6G_RQVD7=v7b6S-muiZBYV7PEykTHOTM23i-BL=wcA5z=4Qg@mail.gmail.com>
	<CAD6G_RQ130TunwZDL+8vwx__8NsfzE0AfcfnS7z5OXtZF5T8xQ@mail.gmail.com>
	<1393975344.4632.10.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<CAD6G_RTVVb2qdU43PqKm3BAD2-pvVcs_O=Wck2SCBhRRV-d+Lw@mail.gmail.com>
	<1393992738.4632.15.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<CAD6G_RR=y+myvtEpa3YKiOx_8LR=Ad_nHUxuaXKakfKKyjuEaw@mail.gmail.com>
	<1394002230.4632.28.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	Nithin Nayak Sujir <nsujir@broadcom.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:50249 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757036AbaCEUCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 15:02:54 -0500
In-Reply-To: <1394002230.4632.28.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 5, 2014 at 12:20 PM, Michael Chan <mchan@broadcom.com> wrote:
> On Wed, 2014-03-05 at 11:43 +0530, Jagan Teki wrote:
>> As per your point I've a question here like - the status block is not properly
>> updated (DMA'ed), does this depends on the address range we are advertised
>> on PCIe ranges filed to make sure to use EP-
>> http://devicetree.org/Device_Tree_Usage#PCI_Host_Bridge
>
> The status block is in host memory (CPU memory).  This memory is
> allocated by the driver.  The DMA address of the status block is then
> programmed into the NIC register HOSTCC_STATUS_BLK_HOST_ADDR so that the
> NIC knows where to DMA the status block.  When there is an event, the
> NIC DMAs a new status block and then generates IRQ.
>
> The status block is not in PCI memory.  PCI memory is where the
> registers are mapped.  Hope this helps.

Thanks this really help my understanding.

BTW: I got all 0's on tnapi->hw_status, looks like host memory contents were
violated or not-been updated properly I guess.

thanks!
-- 
Jagan.
