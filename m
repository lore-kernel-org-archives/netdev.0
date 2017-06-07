From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Return failure on attempted mtu change
Date: Wed, 07 Jun 2017 15:03:12 -0400 (EDT)
Message-ID: <20170607.150312.516522630251819525.davem@davemloft.net>
References: <103eefae-37aa-a30a-4027-5a9c8def3d3f@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com
To: jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33970 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbdFGTDO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 15:03:14 -0400
In-Reply-To: <103eefae-37aa-a30a-4027-5a9c8def3d3f@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>
Date: Tue, 6 Jun 2017 16:55:52 -0500

> Changing the mtu is currently not supported in the ibmvnic driver.
> 
> Implement .ndo_change_mtu in the driver so that attempting to use ifconfig
> to change the mtu will fail and present the user with an error message.
> 
> Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>

Applied, thanks.
