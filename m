From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Fix multicast device ioctl checks
Date: Wed, 26 Mar 2008 02:12:47 -0700 (PDT)
Message-ID: <20080326.021247.33844390.davem@davemloft.net>
References: <47E8F61D.8040403@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50130
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752286AbYCZJMr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 05:12:47 -0400
In-Reply-To: <47E8F61D.8040403@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 25 Mar 2008 13:54:53 +0100

> commit 33fb000e9d0b9b20c226383ce775f06fdcd426bc
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Tue Mar 25 13:53:52 2008 +0100
> 
>     [NET]: Fix multicast device ioctl checks
>     
>     SIOCADDMULTI/SIOCDELMULTI check whether the driver has a set_multicast_list
>     method to determine whether it supports multicast. Drivers implementing
>     secondary unicast support use set_rx_mode however.
>     
>     Check for both dev->set_multicast_mode and dev->set_rx_mode to determine
>     multicast capabilities.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied and queued up for -stable, thanks!
