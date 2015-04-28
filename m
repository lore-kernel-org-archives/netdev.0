From: Toan Pham <tpham3783@gmail.com>
Subject: Re: [Problem] broadcom tg3 network driver disconnects under high load
Date: Tue, 28 Apr 2015 16:06:47 -0400
Message-ID: <CAGNmLEOJxarDZxmoXQfruPQ3RP89=h_zOTfBw-Fzq+Vizg315g@mail.gmail.com>
References: <CAGNmLEMbyR6-1WSyPRZQhLanH_UB7xb5cVVQ9N625bvdhbA6MA@mail.gmail.com>
	<1429908991.3920.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<CAGNmLEMB-hpG_TW3qQGbiHM2Vfd30P=D5H3_ioeY56+iKt14hA@mail.gmail.com>
	<1430244665.6888.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	<1430247712.26841.18.camel@prashant>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Michael Chan <mchan@broadcom.com>, sanjeevb@broadcom.com,
	netdev@vger.kernel.org
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:35200 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030690AbbD1UGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 16:06:48 -0400
Received: by iejt8 with SMTP id t8so27395830iej.2
        for <netdev@vger.kernel.org>; Tue, 28 Apr 2015 13:06:48 -0700 (PDT)
In-Reply-To: <1430247712.26841.18.camel@prashant>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We were able to reproduce this issue internally only with iommu enabled.

My last test to collect lspci-info took about 5 hours over a gigabit
network for the bug to show up.  My setup was running 3 tx scp
sessions, each transferring a 1GB file outbound, and 1 rx scp session
copying another 1GB file inbound.  In a production environment with
the BCM5762 NIC running as a server, I observed that the failure rate
is about 1.65/week.  Please perform a similar test with iommu
disabled, and leave it running for days if need be.


>  Meanwhile can you try the attached patch and see if you are able to reproduce the problem ?

No problem.  I will apply the patch to kernel 4.0 and report back the
result.  Let me know if you need me to turn on any debug options like
pcie trace, dev debug etc....  Thanks
