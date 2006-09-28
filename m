From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [RFC] let mortals use ethtool
Date: Thu, 28 Sep 2006 13:17:04 -0700
Message-ID: <1159474625.3741.6.camel@rh4>
References: <20060928122514.112a19a8@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:10248 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1161178AbWI1UUj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 16:20:39 -0400
To: "Stephen Hemminger" <shemminger@osdl.org>
In-Reply-To: <20060928122514.112a19a8@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-28 at 12:25 -0700, Stephen Hemminger wrote:

> +	/* Allow some commands to be done by anyone */
> +	switch(ethcmd) {
> +	case ETHTOOL_GSET:
> +	case ETHTOOL_GDRVINFO:
> +	case ETHTOOL_GREGS:
> +	case ETHTOOL_GWOL:
> +	case ETHTOOL_GMSGLVL:
> +	case ETHTOOL_GLINK:
> +	case ETHTOOL_GCOALESCE:
> +	case ETHTOOL_GRINGPARAM:
> +	case ETHTOOL_GPAUSEPARAM:
> +	case ETHTOOL_GRXCSUM:
> +	case ETHTOOL_GTXCSUM:
> +	case ETHTOOL_GSG:
> +	case ETHTOOL_GSTRINGS:
> +	case ETHTOOL_PHYS_ID:
> +	case ETHTOOL_GSTATS:
> +	case ETHTOOL_GTSO:
> +	case ETHTOOL_GPERMADDR:
> +	case ETHTOOL_GUFO:
> +	case ETHTOOL_GGSO:

I'm against letting normal users do ETHTOOL_GREGS and ETHTOOL_PHYS_ID.
Dumping 64K worth of registers and blinking the LEDs should be
restricted.  But I have no problem doing these checks in the driver if
necessary.

