From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4 : Disable recursive mailbox commands
 when enabling vi
Date: Tue, 05 Aug 2014 16:49:33 -0700 (PDT)
Message-ID: <20140805.164933.722857698851737276.davem@davemloft.net>
References: <1407279923-9288-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hariprasad@chelsio.com, leedom@chelsio.com
To: anish@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751963AbaHEXte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 19:49:34 -0400
In-Reply-To: <1407279923-9288-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anish Bhatt <anish@chelsio.com>
Date: Tue,  5 Aug 2014 16:05:23 -0700

> Enabling a Virtual Interface can result in an interrupt during the processing
>  of the VI Enable command and, in some paths, result in an attempt to issue
> another command in the interrupt context, eventually crashing the system. Thus,
>  we disable interrupts during the course of the VI Enable command and ensure 
> enable doesn't sleep.
> 
> Signed-off-by: Anish Bhatt <anish@chelsio.com>
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied.
