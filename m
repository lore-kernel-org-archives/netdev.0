From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/rds: zero last byte for strncpy
Date: Fri, 08 Mar 2013 00:36:30 -0500 (EST)
Message-ID: <20130308.003630.1150878411855053823.davem@davemloft.net>
References: <51356FED.4070909@asianux.com>
	<1362502844.2791.32.camel@bwh-desktop.uk.solarflarecom.com>
	<513958C4.1020404@asianux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, David.Laight@ACULAB.COM,
	venkat.x.venkatsubra@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org
To: gang.chen@asianux.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751598Ab3CHFgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 00:36:31 -0500
In-Reply-To: <513958C4.1020404@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Gang <gang.chen@asianux.com>
Date: Fri, 08 Mar 2013 11:19:32 +0800

> 
>   for NUL terminated string, need be always sure '\0' in the end.
> 
> additional info:
>   strncpy will pads with zeroes to the end of the given buffer.
>   should initialise every bit of memory that is going to be copied to userland
> 
> 
> Signed-off-by: Chen Gang <gang.chen@asianux.com>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
