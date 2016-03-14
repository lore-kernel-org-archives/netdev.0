From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Driver: Vmxnet3: Fix regression caused by cec0556
Date: Mon, 14 Mar 2016 15:28:45 -0400 (EDT)
Message-ID: <20160314.152845.1840060808684295471.davem@davemloft.net>
References: <1457731784-96240-1-git-send-email-skhare@vmware.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pv-drivers@vmware.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, gyang@vmware.com
To: skhare@vmware.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755658AbcCNT2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:28:47 -0400
In-Reply-To: <1457731784-96240-1-git-send-email-skhare@vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shrikrishna Khare <skhare@vmware.com>
Date: Fri, 11 Mar 2016 13:29:44 -0800

> don't pass uninitialized flags to spin_unlock_irqrestore.
> 
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Shrikrishna Khare <skhare@vmware.com>
> Signed-off-by: Guolin Yang <gyang@vmware.com>

Sorry, I noticed Arnd's version of this fix first and therefore applied
his version.
