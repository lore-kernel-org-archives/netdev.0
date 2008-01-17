From: Makito SHIOKAWA <mshiokawa@miraclelinux.com>
Subject: Re: [PATCH 3/4] bonding: Fix work rearming
Date: Thu, 17 Jan 2008 14:30:36 +0900
Message-ID: <478EE7FC.4040301@miraclelinux.com>
References: <20080115090532.GB1696@ff.dom.local> <478D77D7.60703@miraclelinux.com> <20080116133646.GE2307@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Makito SHIOKAWA <mshiokawa@miraclelinux.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:30823 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbYAQFc2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 00:32:28 -0500
In-Reply-To: <20080116133646.GE2307@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But, since during this change from sysfs cancel_delayed_work_sync()
> could be probably used, and it's rather efficient with killing
> rearming works, it seems this check could be unnecessary yet.
What going to be cancelled in bonding_store_miimon() when setting miimon to 0 
is arp monitor, not mii monitor. So, this check will be needed to stop 
rearming mii monitor when value 0 is set to miimon.

-- 
Makito SHIOKAWA
MIRACLE LINUX CORPORATION
