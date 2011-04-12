From: Jon Mason <jdmason@kudzu.us>
Subject: Re: [net-next PATCH 1/3] vxge: always enable hardware time stamp
Date: Tue, 12 Apr 2011 10:36:06 -0500
Message-ID: <20110412153604.GA1433@kudzu.us>
References: <1302297083-22665-1-git-send-email-jdmason@kudzu.us>
 <20110410.185845.70188298.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:37732 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757597Ab1DLPgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 11:36:11 -0400
Received: by yia27 with SMTP id 27so2590411yia.19
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2011 08:36:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20110410.185845.70188298.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 10, 2011 at 06:58:45PM -0700, David Miller wrote:
> From: Jon Mason <jdmason@kudzu.us>
> Date: Fri,  8 Apr 2011 16:11:21 -0500
> 
> > Hardware time stamp calculation can only be enabled by the privileged
> > function. Enable it always by default and simply use the ethtool
> > interface to set a flag to indicate whether or not the respective
> > function driver should indicate the timestamp along with the received
> > packet.
> > 
> > Also, make certain fields in vxge_hw_device_config bit-fields to reduce
> > the size of the struct.
> > 
> > Signed-off-by: Jon Mason <jdmason@kudzu.us>
> 
> Doesn't this have some performance or latency impact?

It is all done in hardware by replacing the CRC with the HWTS value.
So, no perf or latency issues there.  It still only handles the HWTS
in receive if it is enabled in software via the ioctl. 

> 
> I think it should be stay off by default, people who want this know
> they want it and can turn it on if they want to.
