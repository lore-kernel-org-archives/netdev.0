From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next 0/2] Move hwmon support out of switch and into
 PHYs.
Date: Wed, 11 Jan 2017 12:00:44 -0800
Message-ID: <20170111200044.GB7282@roeck-us.net>
References: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
 <87vatljzlo.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170111173741.GB13033@lunn.ch>
 <20170111180018.GC22289@roeck-us.net>
 <20170111191643.GC13033@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:37626 "EHLO
        bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932087AbdAKUAr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 15:00:47 -0500
Content-Disposition: inline
In-Reply-To: <20170111191643.GC13033@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2017 at 08:16:43PM +0100, Andrew Lunn wrote:
> >  This makes it kind
> > of a circular argument (not that the dsa hwmon driver supports the
> > new API anyway, but still).
> 
> Actually, the code i posted does. I didn't just move it, i re-wrote it
> to use devm_hwmon_device_register_with_info().
> 
Cool. Sorry, I didn't remember. Then maybe you should ask for the core
to support the necessary callback ;-).

Guenter
