From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/2] net: dsa: make "label" property optional
 for dsa2
Date: Fri, 6 Jan 2017 23:20:08 +0100
Message-ID: <20170106222008.GC10626@lunn.ch>
References: <20170106220043.21280-1-vivien.didelot@savoirfairelinux.com>
 <20170106220043.21280-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Uwe =?iso-8859-1?Q?Kleine-K=F6nig?= <uwe@kleine-koenig.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:47779 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758492AbdAFWUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 17:20:16 -0500
Content-Disposition: inline
In-Reply-To: <20170106220043.21280-2-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If one wants to rename an interface, udev rules can be used as usual.

Hi Vivien

Do you have some examples?

A quick look at udevadm info suggests we can use

ATTR{phys_port_id} and ATTR{phys_switch_id}

Humm, it would be nice to know why the second switch has a
phys_switch_id of 01000000.

How is systemd naming them without udev rules?

    Andrew
