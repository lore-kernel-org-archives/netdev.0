From: Shreyas Bhatewara <sbhatewara@vmware.com>
Subject: Re: [PATCH net-next 3/3] ethtool: Define and apply a default policy
 for RX flow hash indirection
Date: Thu, 15 Dec 2011 19:38:54 -0800 (PST)
Message-ID: <8201083.332014.1324006734086.JavaMail.root@zimbra-prod-mbox-5.vmware.com>
References: <1323993409.2773.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com,
	Matt Carlson <mcarlson@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Dimitris Michailidis <dm@chelsio.com>, netdev@vger.kernel.org,
	"VMware, Inc." <pv-drivers@vmware.com>,
	David Miller <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:2603 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751772Ab1LPDiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 22:38:54 -0500
In-Reply-To: <1323993409.2773.28.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- Original Message -----
> All drivers that support modification of the RX flow hash indirection
> table initialise it in the same way: RX rings are assigned to table
> entries in rotation.  Make that default policy explicit by having
> them
> call a ethtool_rxfh_indir_default() function.
> 
> In the ethtool core, add support for a zero size value for
> ETHTOOL_SRXFHINDIR, which resets the table to this default.
> 
> Partly-suggested-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> The bnx2x, cxgb4 and vmxnet3 changes are compile-tested only.
> 

Looks good. Thanks for working on this.

Acked-by: Shreyas N Bhatewara <sbhatewara@vmware.com>
