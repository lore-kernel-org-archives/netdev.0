From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/3] qlcnic: Fix resource allocation for TX queues
Date: Thu, 02 Jan 2014 17:19:58 -0500 (EST)
Message-ID: <20140102.171958.2254381067633302234.davem@davemloft.net>
References: <1388687925-17882-1-git-send-email-manish.chopra@qlogic.com>
	<1388687925-17882-3-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rajesh.borundia@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750740AbaABWUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 17:20:00 -0500
In-Reply-To: <1388687925-17882-3-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Thu, 2 Jan 2014 13:38:44 -0500

> o TX queues allocation was getting distributed equally among all the
>   functions of the port including VFs and PF. Which was leading to failure
>   in PF's multiple TX queues creation.
> 
> o Instead of dividing queues equally allocate one TX queue for each VF as VF
>   doesn't support multiple TX queues.
> 
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>

Applied.

I did not see the third patch.
