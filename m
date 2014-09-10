From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net:socket: set msg_namelen to 0 if msg_name is
 passed as NULL in msghdr struct from userland.
Date: Tue, 09 Sep 2014 17:36:07 -0700 (PDT)
Message-ID: <20140909.173607.2092550389439938050.davem@davemloft.net>
References: <1410212999-11013-1-git-send-email-ani@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fruggeri@arista.com, netdev@vger.kernel.org, fenner@arista.com,
	travisb@arista.com, hannes@stressinduktion.org,
	matthew.leach@arm.com, eric.dumazet@gmail.com
To: ani@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34334 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001AbaIJAgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 20:36:08 -0400
In-Reply-To: <1410212999-11013-1-git-send-email-ani@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ani Sinha <ani@arista.com>
Date: Mon,  8 Sep 2014 14:49:59 -0700

> Linux manpage for recvmsg and sendmsg calls does not explicitly mention setting msg_namelen to 0 when
> msg_name passed set as NULL. When developers don't set msg_namelen member in msghdr, it might contain garbage
> value which will fail the validation check and sendmsg and recvmsg calls from kernel will return EINVAL. This will
> break old binaries and any code for which there is no access to source code.
> To fix this, we set msg_namelen to 0 when msg_name is passed as NULL from userland.
> 
> Signed-off-by: Ani Sinha <ani@arista.com>

Applied, thanks.
