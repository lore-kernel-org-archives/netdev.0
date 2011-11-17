From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: Don't allow mode change via sysfs with slaves
 present
Date: Thu, 17 Nov 2011 16:04:05 -0500 (EST)
Message-ID: <20111117.160405.368943784304624880.davem@davemloft.net>
References: <1321375482-8637-1-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, fubar@us.ibm.com
To: vfalico@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751322Ab1KQVEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 16:04:13 -0500
In-Reply-To: <1321375482-8637-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Veaceslav Falico <vfalico@redhat.com>
Date: Tue, 15 Nov 2011 17:44:42 +0100

> When changing mode via bonding's sysfs, the slaves are not initialized
> correctly. Forbid to change modes with slaves present to ensure that every
> slave is initialized correctly via bond_enslave().
> 
> Signed-off-by: Veaceslav Falico <vfalico@redhat.com>

Lots of discussion... what is the final verdict on this patch bonding folks?
