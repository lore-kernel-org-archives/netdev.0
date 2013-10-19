From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: fix cipso packet validation when !NETLABEL
Date: Sat, 19 Oct 2013 18:56:22 -0400 (EDT)
Message-ID: <20131019.185622.980013031770966870.davem@davemloft.net>
References: <1382067201-8286-1-git-send-email-seif.mazareeb@gmail.com>
	<1569451.pWV9BbDlmr@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: seif.mazareeb@gmail.com, netdev@vger.kernel.org, seif@marvell.com
To: paul@paul-moore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725Ab3JSW4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:56:24 -0400
In-Reply-To: <1569451.pWV9BbDlmr@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>
Date: Fri, 18 Oct 2013 17:01:11 -0400

> On Thursday, October 17, 2013 08:33:21 PM Seif Mazareeb wrote:
>> From: Seif Mazareeb <seif@marvell.com>
>> 
>> When CONFIG_NETLABEL is disabled, the cipso_v4_validate() function could
>> loop forever in the main loop if opt[opt_iter +1] == 0, this will causing a
>> kernel crash in an SMP system, since the CPU executing this function will
>> stall /not respond to IPIs.
>> 
>> This problem can be reproduced by running the IP Stack Integrity Checker
>> (http://isic.sourceforge.net) using the following command on a Linux machine
>> connected to DUT:
>> 
>> "icmpsic -s rand -d <DUT IP address> -r 123456"
>> wait (1-2 min)
>> 
>> Signed-off-by: Seif Mazareeb <seif@marvell.com>
> 
> This version imported properly for me.
> 
> Acked-by: Paul Moore <paul@paul-moore.com>

Applied and queued up for -stable, thanks!
