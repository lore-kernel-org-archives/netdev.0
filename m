From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] vmxnet3: Don't enable vlan filters in promiscuous
 mode.
Date: Sat, 13 Aug 2011 18:00:59 -0700 (PDT)
Message-ID: <20110813.180059.1188956980281941385.davem@davemloft.net>
References: <1312794947-3163-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scottjg@vmware.com, sbhatewara@vmware.com,
	pv-drivers@vmware.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681Ab1HNBBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2011 21:01:06 -0400
In-Reply-To: <1312794947-3163-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Mon,  8 Aug 2011 02:15:47 -0700

> The vmxnet3 driver enables vlan filters if filtering is enabled for
> any vlan.  In promiscuous mode the filter table is cleared to in
> order to disable filtering.  However, if a vlan device is subsequently
> created that vlan will be added to the filter, re-engaging it.  As a
> result, not only do we not see all the vlans in promiscuous mode, we
> don't even see vlans for which a filter was previously created.
> 
> CC: Scott J. Goldman <scottjg@vmware.com>
> CC: Shreyas Bhatewara <sbhatewara@vmware.com>
> CC: VMware PV-Drivers <pv-drivers@vmware.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
