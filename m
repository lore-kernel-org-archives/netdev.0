From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCHv3 2/2] tg3: Allow ethtool to enable/disable
 loopback.
Date: Tue, 3 May 2011 18:52:06 -0700
Message-ID: <20110504015206.GA28029@mcarlson.broadcom.com>
References: <1304471935-402-1-git-send-email-maheshb@google.com>
 <1304471935-402-2-git-send-email-maheshb@google.com>
 <1304471935-402-3-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	"Micha? Miros?aw" <mirq-linux@rere.qmqm.pl>,
	"Tom Herbert" <therbert@google.com>
To: "Mahesh Bandewar" <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3584 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754121Ab1EDBhS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 21:37:18 -0400
In-Reply-To: <1304471935-402-3-git-send-email-maheshb@google.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 03, 2011 at 06:18:55PM -0700, Mahesh Bandewar wrote:
> +	/*
> +	 * Add loopback capability only for a subset of devices that support
> +	 * MAC-LOOPBACK. Eventually this need to be enhanced to allow INT-PHY
> +	 * loopback for the remaining devices.
> +	 */
> +	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5780 ||
> +	    !tg3_flag(tp, CPMU_PRESENT))
> +		/* Add the loopback capability */
> +		dev->hw_features |= NETIF_F_LOOPBACK;

s/||/&&/

