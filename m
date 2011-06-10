From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 5/5 net-next] cnic, bnx2: Check iSCSI support early
 in bnx2_init_one()
Date: Thu, 9 Jun 2011 17:37:11 -0700
Message-ID: <1307666231.14980.4.camel@HP1>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
 <1307597376-5379-2-git-send-email-mchan@broadcom.com>
 <1307597376-5379-3-git-send-email-mchan@broadcom.com>
 <1307597376-5379-4-git-send-email-mchan@broadcom.com>
 <1307597376-5379-5-git-send-email-mchan@broadcom.com>
 <20110609104228.GA24178@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1607 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754996Ab1FJAoJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 20:44:09 -0400
In-Reply-To: <20110609104228.GA24178@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2011-06-09 at 03:42 -0700, Neil Horman wrote:
> On Wed, Jun 08, 2011 at 10:29:36PM -0700, Michael Chan wrote:
> > Based on earlier patch from Neil Horman <nhorman@tuxdriver.com>
> > 
> > If iSCSI is not supported on a bnx2 device, bnx2_cnic_probe() will
> > return NULL and the cnic device will not be visible to bnx2i.  This
> > will prevent bnx2i from registering and then unregistering during
> > cnic_start() and cause the warning message:
> > 
> > bnx2 0003:01:00.1: eth1: Failed waiting for ULP up call to complete
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> > Cc: Neil Horman <nhorman@tuxdriver.com>
> Thank you Michael.  This also lets you eliminate some dead code in bnx2i_start
> now, since cdev->max_iscsi_conn will never be zero.
> 

This is true for bnx2.  For bnx2x, some devices may support FCoE only
and not iSCSI, so we still need code similar to what you proposed
yesterday.  We'll add that through the scsi tree.

Thanks.


