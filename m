From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH v2] vmxnet3: fix netpoll race condition
Date: Tue, 11 Mar 2014 11:24:08 -0700 (PDT)
Message-ID: <382556580.40955263.1394562248901.JavaMail.root@vmware.com>
References: <1394227527-31082-1-git-send-email-nhorman@tuxdriver.com> <1394448955-19915-1-git-send-email-nhorman@tuxdriver.com> <20140311.131615.1099547048239011196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	pv-drivers@vmware.com, stable@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:41677 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755052AbaCKSYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 14:24:10 -0400
In-Reply-To: <20140311.131615.1099547048239011196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > The fix is to do as other drivers do, and have the poll controller call the
> > top
> > half interrupt handler, which schedules a napi poll properly to recieve
> > frames
> > 
> > Tested by myself, successfully.
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> VMware folks, please review
> 
Neil, thanks for the updated change. It looks good.

Reviewed-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
