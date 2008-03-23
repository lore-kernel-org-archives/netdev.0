From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] route: use read_mostly
Date: Sat, 22 Mar 2008 17:45:11 -0700 (PDT)
Message-ID: <20080322.174511.34162493.davem@davemloft.net>
References: <20080319101219.7d1d3a8b@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58733
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754242AbYCWAoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Mar 2008 20:44:55 -0400
In-Reply-To: <20080319101219.7d1d3a8b@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 19 Mar 2008 10:12:19 -0700

> The route table parameters are set based on system memory and sysctl
> values that almost never change. Also the genid only changes every
> 10 minutes.
> 
> RTprint is defined by never used.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
