From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Correct 'unused variable' warning in
 build.
Date: Wed, 09 Aug 2017 22:31:37 -0700 (PDT)
Message-ID: <20170809.223137.1638208160121174847.davem@davemloft.net>
References: <20170808202618.32133.49772.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51554 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdHJFbh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 01:31:37 -0400
In-Reply-To: <20170808202618.32133.49772.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Tue, 08 Aug 2017 15:26:18 -0500

> Commit a248878d7a1d ("ibmvnic: Check for transport event on driver resume")
> removed the loop to kick irqs on driver resume but didn't remove the now
> unused loop variable 'i'.
> 
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

Applied.
