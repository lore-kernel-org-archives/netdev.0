From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] net: cpsw: fix dual_emac VLAN issue
Date: Tue, 08 Apr 2014 14:15:28 -0400 (EDT)
Message-ID: <20140408.141528.2130884658575478739.davem@redhat.com>
References: <1396969110-3114-1-git-send-email-yegorslists@googlemail.com>
	<1396969110-3114-2-git-send-email-yegorslists@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com
To: yegorslists@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25559 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932649AbaDHSPg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Apr 2014 14:15:36 -0400
In-Reply-To: <1396969110-3114-2-git-send-email-yegorslists@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yegorslists@googlemail.com
Date: Tue,  8 Apr 2014 16:58:30 +0200

> From: Yegor Yefremov <yegorslists@googlemail.com>
> 
> CPSW shows following behavior: some stations in LAN don't
> answer CPSW's ARP request. Kernel 3.2 could talk to all stations in
> the same LAN.
> 
> Use the same cpsw_ale_add_vlan procedure as in kernel 3.2.
> 
> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>

The CPSW driver was not added to the tree until v3.3, so saying
you're restoring behavior that existed in v3.2 doesn't make any
sense at all.
