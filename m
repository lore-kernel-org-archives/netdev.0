From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/1] ethtool: Expose MDI-X status
Date: Fri, 22 May 2009 08:02:24 -0700
Message-ID: <20090522080224.73990f8a@nehalam>
References: <F169D4F5E1F1974DBFAFABF47F60C10A33527C9D@orsmsx507.amr.corp.intel.com>
	<20090522145426.GA8470@clala-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Chaitanya Lala <clala@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52446 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753051AbZEVPC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2009 11:02:29 -0400
In-Reply-To: <20090522145426.GA8470@clala-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 May 2009 07:54:26 -0700
Chaitanya Lala <clala@riverbed.com> wrote:

> The MDI-X status is a useful tool for diagnosing network
> connectivity issues. We expose MDI-X status as a tri-state value
> status which drivers can optionally implement.
> 
> Signed-off-by: Chaitanya Lala <clala@riverbed.com>
> Signed-off-by: Arthur Jones <ajones@riverbed.com>
> ---
>  ethtool-copy.h |    6 ++++++
>  ethtool.c      |   13 +++++++++++++
>  2 files changed, 19 insertions(+), 0 deletions(-)
> 
> diff --git a/ethtool-copy.h b/ethtool-copy.h
> index 3ca4e2c..37bbeaf 100644
> --- a/ethtool-copy.h
> +++ b/ethtool-copy.h
> @@ -23,6 +23,7 @@ struct ethtool_cmd {
>  	__u8	phy_address;
>  	__u8	transceiver;	/* Which transceiver to use */
>  	__u8	autoneg;	/* Enable or disable autonegotiation */
> +	__u8	is_mdix;
>  	__u32	maxtxpkt;	/* Tx pkts before generating tx int */
>  	__u32	maxrxpkt;	/* Rx pkts before generating rx int */
>  	__u16	speed_hi;
>

Is this an ABI change (or are you just reusing a pad hole)?

-- 
