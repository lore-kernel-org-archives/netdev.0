From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is present
Date: Fri, 29 Sep 2006 16:46:56 -0700
Message-ID: <451DB070.8040809@hp.com>
References: <1159565963.3741.23.camel@rh4>	<20060929.154917.125894679.davem@davemloft.net>	<451DA57F.60609@garzik.org> <20060929.160807.28788865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, mchan@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel11.hp.com ([156.153.255.246]:34201 "EHLO palrel11.hp.com")
	by vger.kernel.org with ESMTP id S932294AbWI2Xq5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2006 19:46:57 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060929.160807.28788865.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> It absolutely was not vague, it gave an explicit description of what
> the problem was, down to the transaction type being used by 5706 and
> what the stated rules are in the PCI spec, and it also gave a clear
> indication that the 5706 was in the wrong and that this was believed
> to be a unique situation.

I'm not disagreeing with a per-driver check at the moment, but I thought that 
Michael told us that the masking being attempted by the 5706 was legal:

Michael Chan wrote:
> MSI is defined to be 32-bit write.  The 5706 does 64-bit MSI writes
> with byte enables disabled on the unused 32-bit word.  This is legal
> but causes problems on the AMD 8132 which will eventually stop
> responding after a while.
>
 > ...
> MSI is defined to be 32-bit write.  The 5706 does 64-bit MSI writes
> with byte enables disabled on the unused 32-bit word.  This is legal
> but causes problems on the AMD 8132 which will eventually stop
> responding after a while.
> 

rick jones

