From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vmxnet3: Enable GRO support.
Date: Mon, 27 Jun 2011 22:09:18 -0700 (PDT)
Message-ID: <20110627.220918.1988240421665442557.davem@davemloft.net>
References: <1308961475-25055-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sbhatewara@vmware.com, scottjg@vmware.com,
	pv-drivers@vmware.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48569 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756000Ab1F1FJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 01:09:24 -0400
In-Reply-To: <1308961475-25055-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Fri, 24 Jun 2011 17:24:35 -0700

> When receiving packets from another guest on the same hypervisor, it's
> generally possible to receive large packets because no segmentation is
> necessary and these packets are handled by LRO.  However, when doing
> routing or bridging we must disable LRO and lose this benefit.  In
> these cases GRO can still be used and it is very effective because the
> packets which are segmented in the hypervisor are received very close
> together and can easily be merged.
> 
> CC: Shreyas Bhatewara <sbhatewara@vmware.com>
> CC: Scott Goldman <scottjg@vmware.com>
> CC: VMware PV-Drivers <pv-drivers@vmware.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied, thanks.
