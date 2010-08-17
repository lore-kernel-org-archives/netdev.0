From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 0/7]qlcnic: enhancement and fixes
Date: Tue, 17 Aug 2010 02:43:14 -0700 (PDT)
Message-ID: <20100817.024314.39173338.davem@davemloft.net>
References: <1281682646-15990-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46206
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753007Ab0HQJm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Aug 2010 05:42:56 -0400
In-Reply-To: <1281682646-15990-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Thu, 12 Aug 2010 23:57:19 -0700

> Hi
>    Sending v2 series of 7 patches. In previous set of patches author
>    email id was incorrect and a minor fix in lro/rxcsum patch.
>    Please ignore v1 patches.

Please respin this against net-next-2.6 and resubmit, as-is it doesn't
apply cleanly.

Also, patch #5 is not correct.  Use "netdev_info()" if you want the
netdev stuff printed properly in the link status message.  You're
undoing all of the work made such that all printk's in your driver are
consistent, by using the pr_fmt based interfaces (pr_*(), dev_*(),
netdev_*()).
