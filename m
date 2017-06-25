From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net/iucv: improve endianness handling
Date: Sun, 25 Jun 2017 11:43:11 -0400 (EDT)
Message-ID: <20170625.114311.1334785519251494698.davem@davemloft.net>
References: <20170623173228.70128-1-jwi@linux.vnet.ibm.com>
        <20170623173228.70128-2-jwi@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: jwi@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40378 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbdFYPnN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 11:43:13 -0400
In-Reply-To: <20170623173228.70128-2-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Date: Fri, 23 Jun 2017 19:32:27 +0200

> From: Hans Wippel <hwippel@linux.vnet.ibm.com>
> 
> Use proper endianness conversion for an skb protocol assignment. Given
> that IUCV is only available on big endian systems (s390), this simply
> avoids an endianness warning reported by sparse.
> 
> Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
> Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
> Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>

Applied.
