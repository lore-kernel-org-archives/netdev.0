From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 2/6] Create new file ksz9477.c from KSZ9477 code in
 ksz_common.c
Date: Fri, 8 Sep 2017 02:46:15 +0200
Message-ID: <20170908004615.GB2746@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218CF@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121A06@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60297 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752966AbdIHAqR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 7 Sep 2017 20:46:17 -0400
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121A06@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static void ksz_port_cfg(struct ksz_device *dev, int port, int offset, u8 bits,
> +			 bool set)

Hi Tristram

As you move these functions around, it would be good to change the
prefix to ksz9477_

You have similar functions in the KSZ8795 driver. It is good to keep
the names different. This is useful when looking at stack dumps, etc.

    Andrew
