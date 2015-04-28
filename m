From: Michael Chan <mchan@broadcom.com>
Subject: Re: [Problem] broadcom tg3 network driver disconnects under high
 load
Date: Tue, 28 Apr 2015 11:11:05 -0700
Message-ID: <1430244665.6888.26.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <CAGNmLEMbyR6-1WSyPRZQhLanH_UB7xb5cVVQ9N625bvdhbA6MA@mail.gmail.com>
	 <1429908991.3920.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
	 <CAGNmLEMB-hpG_TW3qQGbiHM2Vfd30P=D5H3_ioeY56+iKt14hA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Toan Pham <tpham3783@gmail.com>, <sanjeevb@broadcom.com>,
	<prashant@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:44866 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030316AbbD1SLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 14:11:38 -0400
In-Reply-To: <CAGNmLEMB-hpG_TW3qQGbiHM2Vfd30P=D5H3_ioeY56+iKt14hA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-04-27 at 22:10 +0000, Toan Pham wrote: 
> Michael,
> 
> 
> Please see attach files.
> 
> BTW, I have also tested this bug on at least 8 different HP 705 PCs
> with the 5762 NIC, so it is probably not a manufacturer defect.  In
> addition, I can never replicate the same issue on the older chipset,
> BCM5761, which can be found on the HP model 6005.  I hope this
> information is helpful.  Thanks

Thanks for the data.  The memory enable bit is cleared and there are
some correctable error bits set.  My colleague Sanjeev will look into
this.

Do you have PCIE Advanced Error Reporting (CONFIG_PCIEAER) enabled in
your kernel?
