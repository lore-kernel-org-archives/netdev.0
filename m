From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 3/3] net/xen-netback: Don't mix hexa and decimal
 with 0x in the printf format
Date: Sun, 21 Jun 2015 09:41:46 -0700 (PDT)
Message-ID: <20150621.094146.1338736741702981872.davem@davemloft.net>
References: <1434481848-26387-1-git-send-email-julien.grall@citrix.com>
	<1434481848-26387-4-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	wei.liu2@citrix.com, ian.campbell@citrix.com,
	netdev@vger.kernel.org
To: julien.grall@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755911AbbFUQaA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:30:00 -0400
In-Reply-To: <1434481848-26387-4-git-send-email-julien.grall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Grall <julien.grall@citrix.com>
Date: Tue, 16 Jun 2015 20:10:48 +0100

> Append 0x to all %x in order to avoid while reading when there is other
> decimal value in the log.
> 
> Also replace some of the hexadecimal print to decimal to uniformize the
> format with netfront.
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>

Applied.
