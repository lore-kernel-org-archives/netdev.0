From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] geneve: Fix races between socket add and
 release.
Date: Thu, 18 Dec 2014 12:38:53 -0500 (EST)
Message-ID: <20141218.123853.1096129541746976478.davem@davemloft.net>
References: <1418783132-99230-1-git-send-email-jesse@nicira.com>
	<1418783132-99230-2-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, azhou@nicira.com
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47004 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbaLRRiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 12:38:55 -0500
In-Reply-To: <1418783132-99230-2-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Tue, 16 Dec 2014 18:25:32 -0800

> Currently, searching for a socket to add a reference to is not
> synchronized with deletion of sockets. This can result in use
> after free if there is another operation that is removing a
> socket at the same time. Solving this requires both holding the
> appropriate lock and checking the refcount to ensure that it
> has not already hit zero.
> 
> Inspired by a related (but not exactly the same) issue in the
> VXLAN driver.
> 
> Fixes: 0b5e8b8e ("net: Add Geneve tunneling protocol driver")
> CC: Andy Zhou <azhou@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied.
