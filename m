From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/2] ibmvnic: Tunable parameter support
Date: Sat, 28 Oct 2017 00:24:14 +0900 (KST)
Message-ID: <20171028.002414.1360135149562986270.davem@davemloft.net>
References: <7a1711ef-a7d6-1eea-90e7-c5c655742cba@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com
To: jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51394 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751654AbdJ0PYV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 11:24:21 -0400
In-Reply-To: <7a1711ef-a7d6-1eea-90e7-c5c655742cba@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>
Date: Thu, 26 Oct 2017 16:22:19 -0500

> This series implements support for changing tunable parameters such as the
> mtu, number of tx/rx queues, and number of buffers per queue via ethtool
> and ifconfig.
> 
> v2: -Fix conflict with Tom's recently applied TSO/SG patches
> v3: -Initialize rc in __ibmvnic_reset fixing build warning
>     -Fix buggy behavior with pending mac changes. Use boolean flag
>      to track if mac change is needed on open rather than relying on
>      the desired->mac pointer.
>     -Directly include tunable structs in the adapter struct rather
>      than keeping pointers, eliminating the need to directly allocate
>      them.

Series applied, thank you.
