From: Sathya Perla <sathya.perla@broadcom.com>
Subject: Re: [PATCH 1/1] be2net: Don't leak iomapped memory on removal.
Date: Fri, 4 Mar 2016 10:30:35 +0530
Message-ID: <CAKvpyk2y2N=1a9XDGq4fW=obn2dHa23+yBSJy+d1jUzhUS7i2Q@mail.gmail.com>
References: <1457044549-10563-1-git-send-email-dougmill@linux.vnet.ibm.com>
	<1457044549-10563-2-git-send-email-dougmill@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Ajit Kumar Khaparde <ajit.khaparde@broadcom.com>,
	Padmanabh Ratnakar <padmanabh.ratnakar@broadcom.com>,
	Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>,
	Somnath Kotur <somnath.kotur@broadcom.com>
To: Douglas Miller <dougmill@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f172.google.com ([209.85.161.172]:35638 "EHLO
	mail-yw0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824AbcCDFAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 00:00:36 -0500
Received: by mail-yw0-f172.google.com with SMTP id g127so36388598ywf.2
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 21:00:35 -0800 (PST)
In-Reply-To: <1457044549-10563-2-git-send-email-dougmill@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 4, 2016 at 4:05 AM, Douglas Miller
<dougmill@linux.vnet.ibm.com> wrote:
> The adapter->pcicfg resource is either mapped via pci_iomap() or
> derived from adapter->db. During be_remove() this resource was ignored
> and so could remain mapped after remove.
>
> Add a flag to track whether adapter->pcicfg was mapped or not, then
> use that flag in be_unmap_pci_bars() to unmap if required.
>
> Signed-off-by: Douglas Miller <dougmill@linux.vnet.ibm.com>

Acked-by: Sathya Perla <sathya.perla@broadcom.com>

Could you pls add the "fixes" tag line to this patch:
Fixes: 25848c901 ("use PCI MMIO read instead of config read for errors")

thanks for the fix,
-Sathya
