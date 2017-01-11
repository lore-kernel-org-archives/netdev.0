From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/2] Move hwmon support out of switch and into
 PHYs.
Date: Wed, 11 Jan 2017 20:19:59 +0100
Message-ID: <20170111191959.GD13033@lunn.ch>
References: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
 <87vatljzlo.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170111173741.GB13033@lunn.ch>
 <0148fe14-a6aa-7f96-6244-74103de05879@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Guenter Roeck <linux@roeck-us.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:56931 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752969AbdAKTUD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 14:20:03 -0500
Content-Disposition: inline
In-Reply-To: <0148fe14-a6aa-7f96-6244-74103de05879@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Are not the *_alarm attributes specifically designed to report such
> things? See Documentation/hwmon/sysfs-interface

Hi Florian

Yes it is, and at the moment, userspace needs to poll it. No need for
in interrupt.

   Andrew
