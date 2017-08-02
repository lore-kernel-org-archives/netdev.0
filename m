From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Initialize SCRQ's during login
 renegotiation
Date: Wed, 02 Aug 2017 10:48:06 -0700 (PDT)
Message-ID: <20170802.104806.1181269709342018784.davem@davemloft.net>
References: <1501617876-17568-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55044 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752404AbdHBRsH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 13:48:07 -0400
In-Reply-To: <1501617876-17568-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Tue,  1 Aug 2017 15:04:36 -0500

> SCRQ resources are freed during renegotiation, but they are not
> re-allocated afterwards due to some changes in the initialization
> process. Fix that by re-allocating the memory after renegotation.
> 
> SCRQ's can also be freed if a server capabilities request fails.
> If this were encountered during a device reset for example,
> SCRQ's may not be re-allocated. This operation is not necessary
> anymore so remove it.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied, thank you.
