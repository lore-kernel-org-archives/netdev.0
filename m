From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmvnic: Call napi_disable instead of napi_enable in
 failure path
Date: Sat, 11 Feb 2017 21:24:31 -0500 (EST)
Message-ID: <20170211.212431.245269233664246874.davem@davemloft.net>
References: <20170210182906.1468.77665.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44476 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751088AbdBLCYc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 21:24:32 -0500
In-Reply-To: <20170210182906.1468.77665.stgit@ltcalpine2-lp14.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Fri, 10 Feb 2017 13:29:06 -0500

> The failure path in ibmvnic_open() mistakenly makes a second call
> to napi_enable instead of calling napi_disable. This can result
> in a BUG_ON for any queues that were enabled in the previous call
> to napi_enable.
> 
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

Applied.
