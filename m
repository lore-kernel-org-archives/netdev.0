From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/2] bnx2: Wait for in-flight DMA to complete at
 probe stage
Date: Mon, 14 Nov 2016 12:28:38 -0500 (EST)
Message-ID: <20161114.122838.1039215178593568702.davem@davemloft.net>
References: <1479013293-21001-1-git-send-email-bhe@redhat.com>
        <8010f40d-e7ca-8fd1-7317-f576289c112f@molgen.mpg.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhe@redhat.com, netdev@vger.kernel.org, michael.chan@broadcom.com,
        linux-kernel@vger.kernel.org, Dept-GELinuxNICDev@cavium.com,
        rasesh.mody@cavium.com, harish.patil@cavium.com,
        frank@undermydesk.org, jsr@dex.edzone.net, jroedel@suse.de,
        dyoung@redhat.com
To: pmenzel@molgen.mpg.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37494 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933258AbcKNR2k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 12:28:40 -0500
In-Reply-To: <8010f40d-e7ca-8fd1-7317-f576289c112f@molgen.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Menzel <pmenzel@molgen.mpg.de>
Date: Mon, 14 Nov 2016 09:25:47 +0100

> Dear Baoquan,
> 
> On 11/13/16 06:01, Baoquan He wrote:
>> This is v2 post.
>>
>> In commit 3e1be7a ("bnx2: Reset device during driver initialization"),
>> firmware requesting code was moved from open stage to probe stage.
>> The reason is in kdump kernel hardware iommu need device be reset in
>> driver probe stage, otherwise those in-flight DMA from 1st kernel
>> will continue going and look up into the newly created io-page tables.
>> However bnx2 chip resetting involves firmware requesting issue, that
>> need be done in open stage.
>>
>> Michale Chan suggested we can just wait for the old in-flight DMA to
>> complete at probe stage, then though without device resetting, we
>> don't need to worry the old in-flight DMA could continue looking up
>> the newly created io-page tables.
>>
>> v1->v2:
>>     Michael suggested to wait for the in-flight DMA to complete at probe
>>     stage. So give up the old method of trying to reset chip at probe
>>     stage, take the new way accordingly.
> 
> thank you for posting the updated series. Could you please resend a v3
> with stable@vger.kernel.org added [1]?

This is not the proper procedure for networking patches.
