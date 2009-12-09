From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/3] netxen: protect device reset by rtnl_lock
Date: Tue, 08 Dec 2009 20:38:32 -0800 (PST)
Message-ID: <20091208.203832.236623008.davem@davemloft.net>
References: <1260051836-14425-1-git-send-email-amit.salecha@qlogic.com>
	<1260051836-14425-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37952
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756364AbZLIEiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:38:25 -0500
In-Reply-To: <1260051836-14425-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Sat,  5 Dec 2009 14:23:54 -0800

> o To prevent race conditions with other reset events.
>   During suspend/resume and firmware recovery, acquire rtnl_lock,
>   while changing interface state.
> 
> Acked-by: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
