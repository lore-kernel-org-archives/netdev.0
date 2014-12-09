From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: Use correct fastpath version for VFs.
Date: Tue, 09 Dec 2014 14:29:36 -0500 (EST)
Message-ID: <20141209.142936.411816221368838187.davem@davemloft.net>
References: <1417690326-11422-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com
To: Yuval.Mintz@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37807 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116AbaLIT3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 14:29:45 -0500
In-Reply-To: <1417690326-11422-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Date: Thu, 4 Dec 2014 12:52:06 +0200

> Our FW can support several fastpath HSI [for backward compatibility] but up
> until now VFs were always configured to use latest fastpath HSI [although VF
> driver might be older and use an older fastpath HSI].
> 
> For linux drivers, the differences are insignificant since driver never
> utilized features that were overridden by the HSI change. But for VMs running
> other operating systems this might be a problem.
> In addition, eventually FW might change fastpath HSI in such a manner that
> backward compatibility WILL break unless configured with proper version.
> 
> This patch fixes the issue for other operating system VMs, as well as lays
> the ground work for forward compatibility in regard to the fastpath HSI.
> 
> Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>

Applied, thanks.
