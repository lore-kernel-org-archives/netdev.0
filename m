From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Client-initiated failover
Date: Tue, 13 Jun 2017 13:00:44 -0400 (EDT)
Message-ID: <20170613.130044.755833774333706377.davem@davemloft.net>
References: <1497288904-15259-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44536 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753189AbdFMRAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 13:00:51 -0400
In-Reply-To: <1497288904-15259-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Mon, 12 Jun 2017 12:35:04 -0500

> The IBM vNIC protocol provides support for the user to initiate
> a failover from the client LPAR in case the current backing infrastructure
> is deemed inadequate or in an error state.
> 
> Support for two H_VIOCTL sub-commands for vNIC devices are required
> to implement this function. These commands are H_GET_SESSION_TOKEN
> and H_SESSION_ERR_DETECTED.
> 
> "[H_GET_SESSION_TOKEN] is used to obtain a session token from a VNIC client
> adapter.  This token is opaque to the caller and is intended to be used in
> tandem with the SESSION_ERROR_DETECTED vioctl subfunction."
> 
> "[H_SESSION_ERR_DETECTED] is used to report that the currently active
> backing device for a VNIC client adapter is behaving poorly, and that
> the hypervisor should attempt to fail over to a different backing device,
> if one is available."
> 
> To provide tools access to this functionality the vNIC driver creates a
> sysfs file that, when written to, will send a request to pHyp to failover
> to a different backing device.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
