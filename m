From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next]: net: remove ifalias on empty given alias
Date: Tue, 23 Sep 2008 13:14:52 -0700
Message-ID: <20080923131452.5d40dd03@extreme>
References: <20080922174346.2ad15d26@extreme>
	<48D948E8.6090804@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37219 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672AbYIWUO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2008 16:14:58 -0400
In-Reply-To: <48D948E8.6090804@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Sep 2008 21:52:08 +0200
Oliver Hartkopp <oliver@hartkopp.net> wrote:

> This patch removes the potentially allocated ifalias when the (new) 
> given alias is empty.
> 
> E.g. when setting
> 
> echo "" > /sys/class/net/eth0/ifalias
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> ---
> 
> Hello Stephen,
> 
> this patch allows to 'remove' or reset the ifalias by giving an empty alias.
> The patch is tested.
> Btw. ifalias is a nice idea also for CAN bus people to 'name' a given 
> CAN bus.
> 
> Thanks & regards,
> Oliver
> 
> 

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Also, udev could put a default value in based on the slot information it has.
