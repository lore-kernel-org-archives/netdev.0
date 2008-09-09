From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] bnx2x: EEH recovery fix
Date: Tue, 09 Sep 2008 12:34:49 +0300
Message-ID: <1220952889.15079.3.camel@lb-tlvb-eliezer>
References: <BD3F7F1EFBA6D54DB056C4FFA45140080334A46036@SJEXCHCCR01.corp.ad.broadcom.com>
 <20080908.124743.30466861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Yitchak Gertner" <yitchak.gertner@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3727 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752238AbYIIJfY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 05:35:24 -0400
In-Reply-To: <20080908.124743.30466861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2008-09-08 at 12:47 -0700, David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Mon, 8 Sep 2008 03:22:32 -0700
> 
> > The EEH mechanism caused a fatal error when using the bnx2x since
> > the driver attempted accessing the device after it was reset by the
> > EEH. This patch sets a proper unload when EEH error is detected
> > without accessing the device.
> >
> > Since the current implementation causes a fatal error, I ask that
> > you will consider applying this patch.
> 
> What user has run into and reported this failure, and is it
> a regression compared to 2.6.26?

IBM found it on PPC and it was more obvious with the DMA mapping
violation. It is broken in the same way on 2.6.26 as well.
 
> 
> That is the criteria for my putting this patch in now.
> 
> Since EEH triggers are an exceedingly corner case error condition,
> this puts this patch even less valid to go in outside of the merge
> window.
> 
If you cannot accept it into 2.6.27, I will re-send it into net-next.
Please let me know.

Thanks,
Eilon


