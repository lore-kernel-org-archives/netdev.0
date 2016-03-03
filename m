From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Fix ibmvnic_capability struct
Date: Thu, 03 Mar 2016 16:36:49 -0500 (EST)
Message-ID: <20160303.163649.1161029923559593071.davem@davemloft.net>
References: <1456849209-4992-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757652AbcCCVgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 16:36:51 -0500
In-Reply-To: <1456849209-4992-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Tue,  1 Mar 2016 10:20:09 -0600

> The ibmvnic_capability struct was defined incorrectly. The last two
> elements of the struct are in the wrong order.  In addition, the number
> element should be 64-bit. Byteswapping functions are updated
> as well.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
