From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH net 5/6] ti_cpsw: Validate hwtstamp_config completely
 before applying it
Date: Thu, 14 Nov 2013 18:19:27 +0530
Message-ID: <5284C6D7.9010906@ti.com>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com> <1384390056.29151.12.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, Felipe Balbi <balbi@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:43790 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752942Ab3KNMtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Nov 2013 07:49:36 -0500
In-Reply-To: <1384390056.29151.12.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 14 November 2013 06:17 AM, Ben Hutchings wrote:
> cpsw_hwtstamp_ioctl() should validate all fields of hwtstamp_config,
> and the hardware version, before making any changes.  Currently it
> sets the TX configuration before validating the rx_filter field
> or that the hardware supports timestamping.
>
> Also correct the error code for hardware versions that don't
> support timestamping.  ENOTSUPP is used by the NFS implementation
> and is not part of userland API; we want EOPNOTSUPP (which glibc
> also calls ENOTSUP, with one 'P').
>
> Untested as I don't have a cross-compiler to hand.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---

Acked-by: Mugunthan V N <mugunthanvnm@gmail.com>

Regards
Mugunthan V N
