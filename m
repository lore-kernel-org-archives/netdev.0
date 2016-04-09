From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Enable use of multiple tx/rx scrqs
Date: Sat, 09 Apr 2016 00:24:14 -0400 (EDT)
Message-ID: <20160409.002414.1397876007087320930.davem@davemloft.net>
References: <57053E33.6020706@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tlfalcon@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org
To: jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbcDIEYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 00:24:21 -0400
In-Reply-To: <57053E33.6020706@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>
Date: Wed, 6 Apr 2016 11:49:55 -0500

> Enables the use of multiple transmit and receive scrqs allowing the ibmvnic
> driver to take advantage of multiqueue functionality. To achieve this, the
> driver must implement the process of negotiating the maximum number of
> queues allowed by the server. Initially, the driver will attempt to login
> with the maximum number of tx and rx queues supported by the server. If
> the server fails to allocate the requested number of scrqs, it will return
> partial success in the login response. In this case, we must reinitiate
> the login process from the request capabilities stage and attempt to login
> requesting fewer scrqs.
> 
> Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>

Applied, thanks.
