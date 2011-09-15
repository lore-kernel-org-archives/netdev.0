From: David Miller <davem@redhat.com>
Subject: Re: [net-next] MII: fix Kconfig dependencies for MII
Date: Thu, 15 Sep 2011 15:49:20 -0400 (EDT)
Message-ID: <20110915.154920.2090436027565433425.davem@redhat.com>
References: <1316071394-18195-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934532Ab1IOTtW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Sep 2011 15:49:22 -0400
In-Reply-To: <1316071394-18195-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 15 Sep 2011 00:23:14 -0700

> MII Kconfig option is apart of the core networking drivers and
> by default NET_CORE is enabled so drivers selecting MII will
> have MII enabled as well.  It was found using the randconfig
> option during testing, MII would be selected but NET_CORE
> could be disabled.  This caused a dependency error.
> 
> Resolved the dependency by selecting NET_CORE when MII is
> selected.
> 
> Reported-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>

Applied, thanks Jeff.
