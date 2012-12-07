From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] chelsio: remove get_clock and use ktime_get
Date: Fri, 07 Dec 2012 12:56:48 -0500 (EST)
Message-ID: <20121207.125648.130067551181714428.davem@davemloft.net>
References: <1354785614-11468-1-git-send-email-jang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57006 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341Ab2LGR4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 12:56:49 -0500
In-Reply-To: <1354785614-11468-1-git-send-email-jang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Glauber <jang@linux.vnet.ibm.com>
Date: Thu,  6 Dec 2012 10:20:14 +0100

> The get_clock() of the chelsio driver clashes with the s390 one.
> The chelsio helper reads a timespec via ktime just to convert it
> back to ktime. I can see no different outcome from calling
> ktime_get directly.
> 
> Remove the get_clock and use ktime_get directly.
> 
> Signed-off-by: Jan Glauber <jang@linux.vnet.ibm.com>

Applied, thanks.
