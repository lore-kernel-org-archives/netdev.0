From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Report rx buffer return codes as
 netdev_dbg
Date: Mon, 07 Aug 2017 14:01:16 -0700 (PDT)
Message-ID: <20170807.140116.713215354994860117.davem@davemloft.net>
References: <21089a62-0b49-ef34-6eb0-33510a5638c0@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35924 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751891AbdHGVBT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:01:19 -0400
In-Reply-To: <21089a62-0b49-ef34-6eb0-33510a5638c0@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>
Date: Mon, 7 Aug 2017 15:42:30 -0500

> Reporting any return code for a receive buffer as an "rx error" only
> produces alarming noise and the only values that have been observed to be
> used in this field are not error conditions. Change this to a netdev_dbg
> with a more descriptive message.
> 
> Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>

Applied, thanks John.
