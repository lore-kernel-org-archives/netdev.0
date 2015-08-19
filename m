From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/3] D in DSA patches
Date: Wed, 19 Aug 2015 14:25:11 -0700
Message-ID: <CAGVrzcYVc_uLO9kHTX1+=5ieVnqZAWkh-3P72+qsH6gE1d=r0A@mail.gmail.com>
References: <1439848372-4055-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34899 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbbHSVZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 17:25:52 -0400
Received: by iodt126 with SMTP id t126so24764816iod.2
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 14:25:50 -0700 (PDT)
In-Reply-To: <1439848372-4055-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-08-17 14:52 GMT-07:00 Andrew Lunn <andrew@lunn.ch>:
> The D in DSA is distributed, meaning multiple switches can be
> connected together. Currently no mainline system does this, and so the
> code is broken. This patchset contains two fixes, and a small helper.
>
> With three of more switches, the current device tree binding is not
> sufficient to express the routing between the switches. The first
> patch extends the binding, in a backwards compatible way, to allow a
> link between a switch to describe all the switches accessible over the
> link, not just the direct neighbor.
>
> The third patch fixes the port configuration on newer devices for
> links connecting switches.

Little late, but this looks good, thanks Andrew!

>
> Andrew Lunn (3):
>   net: dsa: Allow multi hop routes to be expressed
>   net: dsa: Add dsa_is_dsa_port() helper
>   dsa: mv88e6xxx: Set DSA mode based on chip abilities
>
>  Documentation/devicetree/bindings/net/dsa/dsa.txt | 33 +++++++++++++++----
>  drivers/net/dsa/mv88e6xxx.c                       | 16 +++++----
>  include/net/dsa.h                                 |  5 +++
>  net/dsa/dsa.c                                     | 40 +++++++++++++++++------
>  4 files changed, 71 insertions(+), 23 deletions(-)
>
> --
> 2.5.0
>



-- 
Florian
