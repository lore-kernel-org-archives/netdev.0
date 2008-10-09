From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next 4/6] bnx2: Eliminate TSO header
 modifications.
Date: Thu, 09 Oct 2008 13:56:39 -0700
Message-ID: <1223585799.23468.4.camel@HP1>
References: <1223572568-1298-1-git-send-email-mchan@broadcom.com>
 <1223572568-1298-4-git-send-email-mchan@broadcom.com>
 <20081009.122558.246831931.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2120 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753748AbYJIU6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 16:58:52 -0400
In-Reply-To: <20081009.122558.246831931.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-10-09 at 12:25 -0700, David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Thu,  9 Oct 2008 10:16:06 -0700
> 
> > This is now possible with updated firmware.
> >
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> Nice, applied.
> 
> Quick question, in the intermediate step where we have the
> new firmware (patch #3) but not this change applied (patch
> #4) does TSO still work properly?

It will still work.  The firmware will overwrite the header fields
modified (unnecessarily) by the driver.

> 
> If TSO is bolixed after patch #3 but before patch #4 please
> don't create those kinds of non-bisectable situations in
> the future.  I'd rather you do the firmware update and the
> TSO logic changes all in one go to keep it all working.
> 
> Thanks!
> 


