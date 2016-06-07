From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] qed: IOV series - relax firmware
 requirements
Date: Tue, 07 Jun 2016 15:40:27 -0700 (PDT)
Message-ID: <20160607.154027.1554806910616155317.davem@davemloft.net>
References: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422669AbcFGWk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 18:40:28 -0400
In-Reply-To: <1465121476-32494-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Sun, 5 Jun 2016 13:11:10 +0300

> In order for VFs to work, current implementation demands that the VF's
> requried storm firmware would be exactly the version that was loaded by
> the PF, which is a very harsh requirement.
> This patch series is intended to relax this -
> the recently submitted firmware is intended to be forward/backward
> compatible in its fastpath [slowpath is configured by PF on behalf of VF],
> and so VFs would only be required of having the same major faspath HSI in
> order to work.
> 
> Most of the other patches in this series extend current forward
> compatibilty of driver to reduce chance of breaking PF/VF compatibility
> in the future. A few are unrelated IOV changes.

Series applied, thanks.
