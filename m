From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next  11/15] igb: Expose RSS indirection table for ethtool
Date: Wed, 21 Aug 2013 20:15:29 +0100
Message-ID: <1377112529.634.2.camel@bwh-desktop.uk.level5networks.com>
References: <1377073416-7872-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377073416-7872-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:44853 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752261Ab3HUTPd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 15:15:33 -0400
In-Reply-To: <1377073416-7872-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 01:23 -0700, Jeff Kirsher wrote:
[...]
> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
[...]
> +static int igb_set_rxfh_indir(struct net_device *netdev, const u32 *indir)
> +{
[...]
> +	/* Verify user input. */
> +	for (i = 0; i < IGB_RETA_SIZE; i++)
> +		if (indir[i] > num_queues)
[...]

Should be:
		if (indir[i] >= num_queues)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
