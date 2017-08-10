From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Clean up resources on probe failure
Date: Wed, 09 Aug 2017 22:31:29 -0700 (PDT)
Message-ID: <20170809.223129.928044058658597829.davem@davemloft.net>
References: <20170808192845.17535.99639.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51550 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750837AbdHJFba (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 01:31:30 -0400
In-Reply-To: <20170808192845.17535.99639.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Tue, 08 Aug 2017 14:28:45 -0500

> Ensure that any resources allocated during probe are released if the
> probe of the driver fails.
> 
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

Applied, but:

> +
> +ibmvnic_register_fail:
> +	device_remove_file(&dev->dev, &dev_attr_failover);
> +	
   ^^^^^^

That last line has trailing whitespace, which I had to fix up.

Please take care of this next time.
