From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Fix endian error when requesting device
 capabilities
Date: Wed, 15 Feb 2017 14:48:53 -0500 (EST)
Message-ID: <20170215.144853.563005548603650125.davem@davemloft.net>
References: <1487176331-16256-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38278 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750719AbdBOTs6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 14:48:58 -0500
In-Reply-To: <1487176331-16256-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 15 Feb 2017 10:32:11 -0600

> When a vNIC client driver requests a faulty device setting, the
> server returns an acceptable value for the client to request.
> This 64 bit value was incorrectly being swapped as a 32 bit value,
> resulting in loss of data. This patch corrects that by using
> the 64 bit swap function.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
