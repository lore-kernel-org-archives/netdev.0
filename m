From: Paul Menzel <pmenzel@molgen.mpg.de>
Subject: Re: [PATCH v2 0/2] bnx2: Wait for in-flight DMA to complete at probe
 stage
Date: Mon, 14 Nov 2016 09:25:47 +0100
Message-ID: <8010f40d-e7ca-8fd1-7317-f576289c112f@molgen.mpg.de>
References: <1479013293-21001-1-git-send-email-bhe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Dept-GELinuxNICDev@cavium.com,
        rasesh.mody@cavium.com, harish.patil@cavium.com,
        frank@undermydesk.org, jsr@dex.edzone.net, jroedel@suse.de,
        dyoung@redhat.com
To: Baoquan He <bhe@redhat.com>, netdev@vger.kernel.org,
        michael.chan@broadcom.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.molgen.mpg.de ([141.14.17.9]:33185 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752422AbcKNIZu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 03:25:50 -0500
In-Reply-To: <1479013293-21001-1-git-send-email-bhe@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Baoquan,

On 11/13/16 06:01, Baoquan He wrote:
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

thank you for posting the updated series. Could you please resend a v3 
with stable@vger.kernel.org added [1]?


Kind regards,

Paul


[1] https://www.kernel.org/doc/Documentation/stable_kernel_rules.txt
