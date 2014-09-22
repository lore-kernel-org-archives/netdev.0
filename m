From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] qlge: Fix compilation warning and update
 maintainers
Date: Mon, 22 Sep 2014 14:36:14 -0400 (EDT)
Message-ID: <20140922.143614.857768287319294455.davem@davemloft.net>
References: <1411075645-21845-1-git-send-email-harish.patil@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com,
	sudarsana.kalluru@qlogic.com
To: harish.patil@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52768 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbaIVSgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:36:18 -0400
In-Reply-To: <1411075645-21845-1-git-send-email-harish.patil@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harish Patil <harish.patil@qlogic.com>
Date: Thu, 18 Sep 2014 17:27:23 -0400

> From: Harish Patil <harish.patil@qlogic.com>
> 
> This patch series includes the following set of patches:
> 
> - Fix the below warning message:
>   qlge_main.c:1754: warning: 'lbq_desc' may be used uninitialized in this function
> 
> I have made changes according to your earlier feedback:
> 
> "Please fix this differently.  The problem is that the compiler can't see that
> you've done the !length check at the top of the function, so when it later
> sees the while (length > 0) loop, it doesn't know that this loop will always
> execute at least once. Just change that loop to a do { } while() loop and
> the compiler will be able to see everything."
> 
> - Update qlge driver maintainers list
> 
> Please apply this series to net-next.

Series applied, thanks.
