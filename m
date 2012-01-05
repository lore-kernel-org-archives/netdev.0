From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] bna: fix sparse warnings/errors
Date: Thu, 05 Jan 2012 13:23:51 -0500 (EST)
Message-ID: <20120105.132351.1997814540766162705.davem@davemloft.net>
References: <20120104230222.355802239@vyatta.com>
	<20120104230239.111580138@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rmody@brocade.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755489Ab2AESYy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:24:54 -0500
In-Reply-To: <20120104230239.111580138@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 04 Jan 2012 15:02:24 -0800

> This fixes a several sparse warnings.
>   * the __iomem tag was being used incorrectly (needs to be a prefix)
>   * several variables should have been static since local to one file
>   * the firmware was not being forwared declared
>     and was const one place and not the other
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
