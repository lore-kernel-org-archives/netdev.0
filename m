From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 5/5 net-next] cnic, bnx2: Check iSCSI support early in
 bnx2_init_one()
Date: Thu, 9 Jun 2011 06:42:28 -0400
Message-ID: <20110609104228.GA24178@hmsreliant.think-freely.org>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
 <1307597376-5379-2-git-send-email-mchan@broadcom.com>
 <1307597376-5379-3-git-send-email-mchan@broadcom.com>
 <1307597376-5379-4-git-send-email-mchan@broadcom.com>
 <1307597376-5379-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49553 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752971Ab1FIKmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 06:42:36 -0400
Content-Disposition: inline
In-Reply-To: <1307597376-5379-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 08, 2011 at 10:29:36PM -0700, Michael Chan wrote:
> Based on earlier patch from Neil Horman <nhorman@tuxdriver.com>
> 
> If iSCSI is not supported on a bnx2 device, bnx2_cnic_probe() will
> return NULL and the cnic device will not be visible to bnx2i.  This
> will prevent bnx2i from registering and then unregistering during
> cnic_start() and cause the warning message:
> 
> bnx2 0003:01:00.1: eth1: Failed waiting for ULP up call to complete
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> Cc: Neil Horman <nhorman@tuxdriver.com>
Thank you Michael.  This also lets you eliminate some dead code in bnx2i_start
now, since cdev->max_iscsi_conn will never be zero.

Regards
Neil

> 
