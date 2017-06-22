From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] ibmvnic: Correct return code checking for
 ibmvnic_init during probe
Date: Thu, 22 Jun 2017 11:32:40 -0400 (EDT)
Message-ID: <20170622.113240.459131569663342510.davem@davemloft.net>
References: <149807766247.32243.8342302161340985903.stgit@mudbug>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36260 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbdFVPcl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 11:32:41 -0400
In-Reply-To: <149807766247.32243.8342302161340985903.stgit@mudbug>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Wed, 21 Jun 2017 15:41:02 -0500

> The update to ibmvnic_init to allow an EAGAIN return code broke
> the calling of ibmvnic_init from ibmvnic_probe. The code now
> will return from this point in the probe routine if anything
> other than EAGAIN is returned. The check should be to see if rc
> is non-zero and not equal to EAGAIN.
> 
> Without this fix, the vNIC driver can return 0 (success) from
> its probe routine due to ibmvnic_init returning zero, but before
> completing the probe process and registering with the netdev layer.
> 
> Fixes: 6a2fb0e99f9c (ibmvnic: driver initialization for kdump/kexec)
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>

Applied.
