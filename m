From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] macvtap add missing ioctls - fix wrapping
Date: Tue, 12 May 2015 23:01:21 -0400 (EDT)
Message-ID: <20150512.230121.330638562727327262.davem@davemloft.net>
References: <1431262215.3278.2.camel@myriabit.com>
	<20150511.134901.959375179450827063.davem@davemloft.net>
	<1431370810.3278.4.camel@myriabit.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: justin@myriabit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933909AbbEMDBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 23:01:23 -0400
In-Reply-To: <1431370810.3278.4.camel@myriabit.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Justin Cormack <justin@myriabit.com>
Date: Mon, 11 May 2015 20:00:10 +0100

> The macvtap driver tries to emulate all the ioctls supported by a normal
> tun/tap driver, however it was missing the generic SIOCGIFHWADDR and
> SIOCSIFHWADDR ioctls to get and set the mac address that are supported
> by tun/tap. This patch adds these.
> 
> Signed-off-by: Justin Cormack <justin@netbsd.org>

Applied to net-next, thanks.
