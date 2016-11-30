From: Jan =?ISO-8859-1?Q?L=FCbbe?= <jlu@pengutronix.de>
Subject: Re: [PATCH 3/6] net: ethernet: ti: cpts: add support of cpts
 HW_TS_PUSH
Date: Wed, 30 Nov 2016 12:08:20 +0100
Message-ID: <1480504100.9183.72.camel@pengutronix.de>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
         <20161128230428.6872-4-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org, Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:42455 "EHLO
        metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754813AbcK3LIZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 06:08:25 -0500
In-Reply-To: <20161128230428.6872-4-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2016-11-28 at 17:04 -0600, Grygorii Strashko wrote:
> This patch adds support of the CPTS HW_TS_PUSH events which are generated
> by external low frequency time stamp channels on TI's OMAP CPSW and
> Keystone 2 platforms. It supports up to 8 external time stamp channels for
> HW_TS_PUSH input pins (the number of supported channel is different for
> different SoCs and CPTS versions, check corresponding Data maual before
> enabling it). Therefore, new DT property "cpts-ext-ts-inputs" is introduced
> for specifying number of available external timestamp channels.

If this only depends on SoC and CTPS, it should be possible to derive
the correct value from the compatible value and possibly a CPTS version
register? If the existing compatible strings are not specific enough,
possible a new one should be added.

Regards,
Jan
-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
