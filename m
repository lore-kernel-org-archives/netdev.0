From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] bnx2: Wait for in-flight DMA to complete at
 probe stage
Date: Mon, 14 Nov 2016 16:21:37 -0500 (EST)
Message-ID: <20161114.162137.1769671597203833028.davem@davemloft.net>
References: <1479013293-21001-1-git-send-email-bhe@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        linux-kernel@vger.kernel.org, Dept-GELinuxNICDev@cavium.com,
        rasesh.mody@cavium.com, harish.patil@cavium.com,
        frank@undermydesk.org, jsr@dex.edzone.net, pmenzel@molgen.mpg.de,
        jroedel@suse.de, dyoung@redhat.com
To: bhe@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1479013293-21001-1-git-send-email-bhe@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoquan He <bhe@redhat.com>
Date: Sun, 13 Nov 2016 13:01:31 +0800

> This is v2 post.
> 
> In commit 3e1be7a ("bnx2: Reset device during driver initialization"),
> firmware requesting code was moved from open stage to probe stage.
> The reason is in kdump kernel hardware iommu need device be reset in
> driver probe stage, otherwise those in-flight DMA from 1st kernel
> will continue going and look up into the newly created io-page tables.
> However bnx2 chip resetting involves firmware requesting issue, that
> need be done in open stage. 
> 
> Michale Chan suggested we can just wait for the old in-flight DMA to
> complete at probe stage, then though without device resetting, we
> don't need to worry the old in-flight DMA could continue looking up 
> the newly created io-page tables.
> 
> v1->v2:
>     Michael suggested to wait for the in-flight DMA to complete at probe
>     stage. So give up the old method of trying to reset chip at probe
>     stage, take the new way accordingly.

Series applied and queued up for -stable, thanks.
