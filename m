From: Dimitris Michailidis <dm@chelsio.com>
Subject: Re: [PATCH net-next 2/3] ethtool: Centralise validation of ETHTOOL_{G,S}RXFHINDIR
 parameters
Date: Thu, 15 Dec 2011 16:51:31 -0800
Message-ID: <4EEA9613.7090501@chelsio.com>
References: <1323993076.2773.23.camel@bwh-desktop> <1323993301.2773.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com,
	Matt Carlson <mcarlson@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11144 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752620Ab1LPAvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2011 19:51:38 -0500
In-Reply-To: <1323993301.2773.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/15/2011 03:55 PM, Ben Hutchings wrote:
> Add a new ethtool operation (get_rxfh_indir_size) to get the
> indirectional table size.  Use this to validate the user buffer size
> before calling get_rxfh_indir or set_rxfh_indir.  Use get_rxnfc to get
> the number of RX rings, and validate the contents of the new
> indirection table before calling set_rxfh_indir.  Remove this
> validation from drivers.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> The bnx2x, cxgb4 and vmxnet3 changes are compile-tested only.

The cxgb4 and core changes look good.

Acked-by: Dimitris Michailidis <dm@chelsio.com>
