From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] qed: RocE & iSCSI infrastructure
Date: Fri, 03 Jun 2016 20:09:28 -0400 (EDT)
Message-ID: <20160603.200928.1525280019631601775.davem@davemloft.net>
References: <1464953735-2585-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rajesh.Borundia@qlogic.com,
	shyam.sundar@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43711 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbcFDAJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 20:09:30 -0400
In-Reply-To: <1464953735-2585-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Fri, 3 Jun 2016 14:35:31 +0300

> We plan on sending 2 new protocol drivers in the imminent future -
> both our RoCE [qedr] and iSCSI [qedi] drivers. As both submissions
> would be rather massive and in order to avoid collisions between them,
> the common infrastructure on the qed side was prepared as an independent
> patch-series to be sent ahead of those 2 submissions.
> 
> This patch series introduces in QED 2 new 'ids' - one for iscsi and
> one for roce. It then goes and adds logic required for configuring
> said protocols in HW. Notice it *doesn't* actually add any client using
> said ids, but rather only the infrastructure to allow their later usage.
> 
> What this patch doesn't contain is the slowpath protocol-configuration
> toward the firmware. I.e., it contains register-setting logic, memory
> allocations, etc., but not actual flow-related configuration specific
> to the protocl. Those would be sent as part of the protocol driver
> submissions.

Series applied to net-next, thanks.
