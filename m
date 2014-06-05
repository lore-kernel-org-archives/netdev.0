From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] qlcnic: Initialize mailbox cmd structure to zero
Date: Thu, 05 Jun 2014 15:06:25 -0700 (PDT)
Message-ID: <20140605.150625.1638199968605912320.davem@davemloft.net>
References: <1401867654-16691-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752202AbaFEWG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:06:26 -0400
In-Reply-To: <1401867654-16691-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Wed, 4 Jun 2014 03:40:54 -0400

> o Uninitialzed fields in mailbox command structure
>   caused commands to time out randomly due to garbage
>   values so initialize it to zero.
> 
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> ---
> Changes in v2: Initialized cmd structure where it is allocated as
> 	       per David Miller's review comment.

Yes, this looks a lot better, applied, thank you.
