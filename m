From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 1/2] tipc: move netlink policies to
 netlink.h
Date: Tue, 05 Jan 2016 16:47:49 -0500 (EST)
Message-ID: <20160105.164749.1356932343853770417.davem@davemloft.net>
References: <1451987777-17421-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: richard.alpe@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbcAEVrv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2016 16:47:51 -0500
In-Reply-To: <1451987777-17421-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>
Date: Tue, 5 Jan 2016 10:56:16 +0100

> Make the c files less cluttered and enable netlink attributes to be
> shared between files. This will prove useful in a future patch where a
> node message will contain a nested network.
> 
> Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
> Acked-by: Jon Maloy <jon.maloy@ericsson.com>

netlink.h is included by more than one file, which means the tables
(might) be instantiated multiple times.

I'd really recommend not putting such tables in a header file that
is used in this way.

Thanks.
