From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmvnic: Handle backing device failover and
 reinitialization
Date: Fri, 19 Aug 2016 17:02:25 -0700 (PDT)
Message-ID: <20160819.170225.1435790645345872728.davem@davemloft.net>
References: <1471538271-10131-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55940 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755137AbcHTAC1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 20:02:27 -0400
In-Reply-To: <1471538271-10131-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Thu, 18 Aug 2016 11:37:51 -0500

> An upcoming feature of IBM VNIC protocol is the ability to configure
> redundant backing devices for a VNIC client. In case of a failure
> on the current backing device, the driver will receive a signal
> from the hypervisor indicating that a failover will occur. The driver
> will then wait for a message from the backing device before 
> establishing a new connection.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
