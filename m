From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] e1000e: fix the build error when PM is disabled
Date: Tue, 18 Mar 2014 13:26:34 -0400 (EDT)
Message-ID: <20140318.132634.1031901441868057758.davem@davemloft.net>
References: <1395127610-3290-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haokexin@gmail.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757151AbaCRR0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:26:36 -0400
In-Reply-To: <1395127610-3290-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 Mar 2014 00:26:49 -0700

> From: Kevin Hao <haokexin@gmail.com>
> 
> The commit 2800209994f8 (e1000e: Refactor PM flows) changed the
> SET_SYSTEM_SLEEP_PM_OPS to open-coded assignment, but forgot to
> protect them with CONFIG_PM_SLEEP. Then cause the following build
> error when PM is disabled:
 ...
> Signed-off-by: Kevin Hao <haokexin@gmail.com>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
