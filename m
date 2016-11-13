From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] bnx2: Wait for in-flight DMA to complete at
 probe stage
Date: Sat, 12 Nov 2016 23:40:39 -0500 (EST)
Message-ID: <20161112.234039.1001224346500132925.davem@davemloft.net>
References: <1478871995-29652-1-git-send-email-bhe@redhat.com>
        <1478871995-29652-3-git-send-email-bhe@redhat.com>
        <20161113041524.GF15325@x1>
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
In-Reply-To: <20161113041524.GF15325@x1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoquan He <bhe@redhat.com>
Date: Sun, 13 Nov 2016 12:15:24 +0800

> In-flight DMA from 1st kernel could continue going in kdump kernel.
> New io-page table has been created before bnx2 does reset at open stage.
> We have to wait for the in-flight DMA to complete to avoid it look up
> into the newly created io-page table at probe stage.
> 
> Suggested-by: Michael Chan <michael.chan@broadcom.com>
> Signed-off-by: Baoquan He <bhe@redhat.com>
> ---
> v1->v2:
>     Michael suggested to wait for the in-flight DMA to complete at probe
>     stage. So give up the old method of trying to reset chip at probe
>     stage, take the new way accordingly.

Patch updates don't work this way.

When you update a patch that is part of a patch series, you must
resubmit the entire series anew.

Thank you.
