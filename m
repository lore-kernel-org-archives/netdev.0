From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/3] vxge: always enable hardware time stamp
Date: Tue, 12 Apr 2011 11:01:51 -0700 (PDT)
Message-ID: <20110412.110151.71117421.davem@davemloft.net>
References: <1302297083-22665-1-git-send-email-jdmason@kudzu.us>
	<20110410.185845.70188298.davem@davemloft.net>
	<20110412153604.GA1433@kudzu.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdmason@kudzu.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36657
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758080Ab1DLSC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 14:02:27 -0400
In-Reply-To: <20110412153604.GA1433@kudzu.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Mason <jdmason@kudzu.us>
Date: Tue, 12 Apr 2011 10:36:06 -0500

> On Sun, Apr 10, 2011 at 06:58:45PM -0700, David Miller wrote:
>> From: Jon Mason <jdmason@kudzu.us>
>> Date: Fri,  8 Apr 2011 16:11:21 -0500
>> 
>> > Hardware time stamp calculation can only be enabled by the privileged
>> > function. Enable it always by default and simply use the ethtool
>> > interface to set a flag to indicate whether or not the respective
>> > function driver should indicate the timestamp along with the received
>> > packet.
>> > 
>> > Also, make certain fields in vxge_hw_device_config bit-fields to reduce
>> > the size of the struct.
>> > 
>> > Signed-off-by: Jon Mason <jdmason@kudzu.us>
>> 
>> Doesn't this have some performance or latency impact?
> 
> It is all done in hardware by replacing the CRC with the HWTS value.
> So, no perf or latency issues there.  It still only handles the HWTS
> in receive if it is enabled in software via the ioctl. 

Ok, thanks for the clarification, I'll apply this patch set.
