From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] skge: race with workq and RTNL
Date: Tue, 20 Feb 2007 11:18:43 -0500
Message-ID: <45DB1F63.20107@pobox.com>
References: <20070216153739.387d0b97@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44496 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965243AbXBTQSq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:18:46 -0500
In-Reply-To: <20070216153739.387d0b97@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> If a workqueue function that needs RTNL is running when skge_down
> is called then a deadlock is possible. Fix by only clearing the timer,
> and handling the flush_scheduled_work on removal. This work queue is only
> ever used for the old fiber based boards.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

applied


