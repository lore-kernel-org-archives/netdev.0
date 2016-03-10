From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/2] qlcnic fixes
Date: Thu, 10 Mar 2016 16:16:35 -0500 (EST)
Message-ID: <20160310.161635.432267926229064181.davem@davemloft.net>
References: <1457422798-17981-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216AbcCJVQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 16:16:37 -0500
In-Reply-To: <1457422798-17981-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Tue, 8 Mar 2016 02:39:56 -0500

> This series adds following fixes.
> 
> o While processing mailbox if driver gets a spurious mailbox
>   interrupt it leads into premature completion of a next
>   mailbox request. Added a guard against this by checking current
>   state of mailbox and ignored spurious interrupt.
>   Added a stats counter to record this condition.
> 
> v2:
> 
> o Added patch that removes usage of atomic_t as we are not implemeting
>   atomicity by using atomic_t value.
> 
> Please apply these fixes to net.

As explained in other list postings, 'net' is basically closed for this
release cycle, so I applied this series to 'net-next'.

Let me know if you'd like me to therefore queue these changes up for
-stable.

Thanks.
