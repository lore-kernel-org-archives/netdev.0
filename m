From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 2/3] netxen:fix napi intr enable check
Date: Tue, 08 Dec 2009 20:38:37 -0800 (PST)
Message-ID: <20091208.203837.59887631.davem@davemloft.net>
References: <1260051836-14425-1-git-send-email-amit.salecha@qlogic.com>
	<1260051836-14425-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37957
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756778AbZLIEia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:38:30 -0500
In-Reply-To: <1260051836-14425-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Sat,  5 Dec 2009 14:23:55 -0800

> o netif_running() check for enabling interrupt at end of napi poll is
>   not enough to cover firmwar recovery. Instead test __NX_DEV_UP bit.
> o Avoid re-entry into to netxen_nic_down() with __NX_DEV_UP bit check.
> 
> Acked-by: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied.
