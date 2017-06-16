From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ibmvnic: driver initialization for kdump/kexec
Date: Fri, 16 Jun 2017 15:21:38 -0400 (EDT)
Message-ID: <20170616.152138.1813416619974791339.davem@davemloft.net>
References: <20170615184809.42218.80768.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37438 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750864AbdFPTVl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 15:21:41 -0400
In-Reply-To: <20170615184809.42218.80768.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Thu, 15 Jun 2017 14:48:09 -0400

> When booting into the kdump/kexec kernel, pHyp and vios
> are not prepared for the initialization crq request and
> a failover transport event is generated. This is not
> handled correctly.
> 
> At this point in initialization the driver is still in
> the 'probing' state and cannot handle a full reset of the
> driver as is normally done for a failover transport event.
> 
> To correct this we catch driver resets while still in the
> 'probing' state and return EAGAIN. This results in the
> driver tearing down the main crq and calling ibmvnic_init()
> again.
> 
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

Applied to net-next.
