From: Daniel Kim <dkim@playmechanix.com>
Subject: Re: [Problem] Broadcom BCM5762 Ethernet tg3 times out with stack trace
Date: Thu, 1 Jun 2017 17:01:27 -0500
Message-ID: <CANeD+K-O_umVCz-5O68TH9R9ADa22UJungTuYoHjSZRvvNrhmw@mail.gmail.com>
References: <CAMet4B7c_wT3rk2DBcTBmdMpPpHuiuWSEae=VLrVH_tfcZT1_g@mail.gmail.com>
 <CANeD+K_ojPPUS2QtHRg+1o4EZaCSFcaa=dDPfkR2tUYNwdGNiw@mail.gmail.com>
 <CACKFLi=762N5LzmcOE4dPS_1Op8EsJ8QJBRFqZySaSx7SNb1bg@mail.gmail.com> <CANeD+K_hYMuC_AqB97fjBt+NXCMi5r8KzCNpcvFBk5obKL_k=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Siva Reddy Kallam <siva.kallam@broadcom.com>,
        Prashant Sreedharan <prashant@broadcom.com>,
        Michael Chan <mchan@broadcom.com>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:33470 "EHLO
        mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751078AbdFAWB2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2017 18:01:28 -0400
Received: by mail-io0-f182.google.com with SMTP id b184so3879741ioe.0
        for <netdev@vger.kernel.org>; Thu, 01 Jun 2017 15:01:28 -0700 (PDT)
In-Reply-To: <CANeD+K_hYMuC_AqB97fjBt+NXCMi5r8KzCNpcvFBk5obKL_k=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 12, 2017 at 6:12 PM, Daniel Kim <dkim@playmechanix.com> wrote:
> I believe I do have IOMMU enabled. At least the dmesg output seems to
> imply that I do:
> [    1.141948] iommu: Adding device 0000:00:02.0 to group 0
> [    1.142033] iommu: Adding device 0000:00:10.0 to group 1
> [    1.142074] iommu: Adding device 0000:00:10.1 to group 1
> [    1.142119] iommu: Adding device 0000:00:11.0 to group 2
> [    1.142172] iommu: Adding device 0000:00:12.0 to group 3
> [    1.142184] iommu: Adding device 0000:00:12.2 to group 3
> [    1.142234] iommu: Adding device 0000:00:13.0 to group 4
> [    1.142247] iommu: Adding device 0000:00:13.2 to group 4
> [    1.142303] iommu: Adding device 0000:00:14.0 to group 5
> [    1.142315] iommu: Adding device 0000:00:14.2 to group 5
> [    1.142328] iommu: Adding device 0000:00:14.3 to group 5
> [    1.142373] iommu: Adding device 0000:00:14.4 to group 6
> [    1.142417] iommu: Adding device 0000:00:14.5 to group 7
> [    1.142529] iommu: Adding device 0000:00:15.0 to group 8
> [    1.142570] iommu: Adding device 0000:00:15.2 to group 8
> [    1.142639] iommu: Adding device 0000:00:18.0 to group 9
> [    1.142653] iommu: Adding device 0000:00:18.1 to group 9
> [    1.142668] iommu: Adding device 0000:00:18.2 to group 9
> [    1.142682] iommu: Adding device 0000:00:18.3 to group 9
> [    1.142695] iommu: Adding device 0000:00:18.4 to group 9
> [    1.142712] iommu: Adding device 0000:00:18.5 to group 9
> [    1.142725] iommu: Adding device 0000:01:00.0 to group 0
> [    1.142733] iommu: Adding device 0000:01:00.1 to group 0
> [    1.142840] iommu: Adding device 0000:04:00.0 to group 8
> [    1.143305] AMD-Vi: Found IOMMU at 0000:00:00.2 cap 0x40
>
> The last kernel I used where the NIC mostly worked was 4.4.0 (x86-64).
> Even when it worked, it had this issue we've experienced since v3.13
> where the NIC would suddenly become unresponsive. It won't be
> considered disconnected from the network, but RX/TX packets, errors,
> dropped, etc. values displayed with ifconfig would show a number that
> looked suspiciously close to 32-bit INT_MAX.
>
> Since v4.8, I can trigger it much faster and it now prints out a call
> stack and other messages into dmesg.

I'd like to follow up on this since I haven't heard of any updates for
awhile. Is there anything I can do on my end to help?
