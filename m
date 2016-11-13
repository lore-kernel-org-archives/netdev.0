From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH v2 2/2] bnx2: Wait for in-flight DMA to complete at probe stage
Date: Sun, 13 Nov 2016 11:02:01 -0800
Message-ID: <CACKFLinJrbLjEnQfNN+tBn9d+eSSTpx=A4_QUJp1PuMBwYOPqw@mail.gmail.com>
References: <1479013293-21001-1-git-send-email-bhe@redhat.com> <1479013293-21001-3-git-send-email-bhe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        open list <linux-kernel@vger.kernel.org>,
        Dept-GELinuxNICDev@cavium.com, rasesh.mody@cavium.com,
        harish.patil@cavium.com, frank@undermydesk.org, jsr@dex.edzone.net,
        pmenzel@molgen.mpg.de, jroedel@suse.de, dyoung@redhat.com
To: Baoquan He <bhe@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:33256 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753650AbcKMTCC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 14:02:02 -0500
Received: by mail-vk0-f42.google.com with SMTP id 137so49523221vkl.0
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 11:02:02 -0800 (PST)
In-Reply-To: <1479013293-21001-3-git-send-email-bhe@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 12, 2016 at 9:01 PM, Baoquan He <bhe@redhat.com> wrote:
> In-flight DMA from 1st kernel could continue going in kdump kernel.
> New io-page table has been created before bnx2 does reset at open stage.
> We have to wait for the in-flight DMA to complete to avoid it look up
> into the newly created io-page table at probe stage.
>
> Suggested-by: Michael Chan <michael.chan@broadcom.com>
> Signed-off-by: Baoquan He <bhe@redhat.com>

Acked-by: Michael Chan <michael.chan@broadcom.com>
