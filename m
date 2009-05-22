From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] ethtool: Expose MDI-X status
Date: Fri, 22 May 2009 16:03:30 +0100
Message-ID: <1243004610.3192.18.camel@achroite>
References: <F169D4F5E1F1974DBFAFABF47F60C10A33527C9D@orsmsx507.amr.corp.intel.com>
	 <20090522145426.GA8470@clala-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Chaitanya Lala <clala@riverbed.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:49551 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757209AbZEVPDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2009 11:03:35 -0400
In-Reply-To: <20090522145426.GA8470@clala-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-05-22 at 07:54 -0700, Chaitanya Lala wrote:
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
[...]

I have already filled this hole in the structure.  See Dave's
net-next-2.6 repository and my previously submitted changes to ethtool
<http://thread.gmane.org/gmane.linux.network/127025>.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

