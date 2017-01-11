From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/2] Move hwmon support out of switch and into
 PHYs.
Date: Wed, 11 Jan 2017 20:16:43 +0100
Message-ID: <20170111191643.GC13033@lunn.ch>
References: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
 <87vatljzlo.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170111173741.GB13033@lunn.ch>
 <20170111180018.GC22289@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56905 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750757AbdAKTQw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 14:16:52 -0500
Content-Disposition: inline
In-Reply-To: <20170111180018.GC22289@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  This makes it kind
> of a circular argument (not that the dsa hwmon driver supports the
> new API anyway, but still).

Actually, the code i posted does. I didn't just move it, i re-wrote it
to use devm_hwmon_device_register_with_info().

   Andrew
