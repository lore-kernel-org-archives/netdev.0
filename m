From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [Problem] broadcom tg3 network driver disconnects under high
 load
Date: Tue, 28 Apr 2015 13:43:01 -0700
Message-ID: <1430253781.26841.21.camel@prashant>
References: <CAGNmLEMbyR6-1WSyPRZQhLanH_UB7xb5cVVQ9N625bvdhbA6MA@mail.gmail.com>
	 <1429908991.3920.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <CAGNmLEMB-hpG_TW3qQGbiHM2Vfd30P=D5H3_ioeY56+iKt14hA@mail.gmail.com>
	 <1430244665.6888.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <1430247712.26841.18.camel@prashant>
	 <CAGNmLEOJxarDZxmoXQfruPQ3RP89=h_zOTfBw-Fzq+Vizg315g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, <sanjeevb@broadcom.com>,
	<netdev@vger.kernel.org>
To: Toan Pham <tpham3783@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:28115 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965966AbbD1UwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 16:52:15 -0400
In-Reply-To: <CAGNmLEOJxarDZxmoXQfruPQ3RP89=h_zOTfBw-Fzq+Vizg315g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-04-28 at 16:06 -0400, Toan Pham wrote:
> > We were able to reproduce this issue internally only with iommu enabled.
> 
> My last test to collect lspci-info took about 5 hours over a gigabit
> network for the bug to show up.  My setup was running 3 tx scp
> sessions, each transferring a 1GB file outbound, and 1 rx scp session
> copying another 1GB file inbound.  In a production environment with
> the BCM5762 NIC running as a server, I observed that the failure rate
> is about 1.65/week.  Please perform a similar test with iommu
> disabled, and leave it running for days if need be.

Sure will try
> 
> 
> >  Meanwhile can you try the attached patch and see if you are able to reproduce the problem ?
> 
> No problem.  I will apply the patch to kernel 4.0 and report back the
> result.  Let me know if you need me to turn on any debug options like
> pcie trace, dev debug etc....  Thanks

If you can collect pcie trace that would be great. Thanks
