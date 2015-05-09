From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvtap add missing ioctls
Date: Sat, 09 May 2015 17:40:17 -0400 (EDT)
Message-ID: <20150509.174017.6956415471104971.davem@davemloft.net>
References: <1430927775.669.2.camel@myriabit.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: justin@myriabit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbEIVkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:40:18 -0400
In-Reply-To: <1430927775.669.2.camel@myriabit.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Justin Cormack <justin@myriabit.com>
Date: Wed, 06 May 2015 16:56:15 +0100

> The macvtap driver tries to emulate all the ioctls supported by a normal tun/tap driver,
> however it was missing the generic SIOCGIFHWADDR and SIOCSIFHWADDR ioctls to get and set
> the mac address that are supported by tun/tap. This patch adds these.
> 
> Signed off by Justin Cormack <justin@netbsd.org>

The correct format of a signoff is "Signed-off-by: " The exact format
is important because scripts, GIT tools, and web applications parse
these tags.

Also please format your commit message to ~80 columns.

Please fix this up and resubmit, thanks.
