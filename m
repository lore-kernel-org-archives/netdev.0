From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/2] ibmvnic: Fix releasing of sub-CRQ IRQs in
 interrupt context
Date: Sat, 29 Oct 2016 17:19:04 -0400 (EDT)
Message-ID: <20161029.171904.1179235664365286645.davem@davemloft.net>
References: <1477589332-513-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53036 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbcJ2VTG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 17:19:06 -0400
In-Reply-To: <1477589332-513-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Thu, 27 Oct 2016 12:28:51 -0500

> Schedule these XPORT event tasks in the shared workqueue
> so that IRQs are not freed in an interrupt context when
> sub-CRQs are released.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> ---
> v2: correct warnings by kbuild bot

Applied.
