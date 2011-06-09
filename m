From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5 net-next] cnic, bnx2: Check iSCSI support early in
 bnx2_init_one()
Date: Wed, 08 Jun 2011 23:53:27 -0700 (PDT)
Message-ID: <20110608.235327.549372211258112268.davem@davemloft.net>
References: <1307597376-5379-3-git-send-email-mchan@broadcom.com>
	<1307597376-5379-4-git-send-email-mchan@broadcom.com>
	<1307597376-5379-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@tuxdriver.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894Ab1FIGzD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 02:55:03 -0400
In-Reply-To: <1307597376-5379-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 8 Jun 2011 22:29:36 -0700

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

Applied.
