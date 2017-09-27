From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/6] mv88e6xxx broadcast flooding in hardware
Date: Wed, 27 Sep 2017 14:28:14 -0400
Message-ID: <87bmlw6loh.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:39812 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbdI0ScE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 14:32:04 -0400
In-Reply-To: <1506464764-12699-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> This patchset makes the mv88e6xxx driver perform flooding in hardware,
> rather than let the software bridge perform the flooding. This is a
> prerequisite for IGMP snooping on the bridge interface.
>
> In order to make hardware broadcasting work, a few other issues need
> fixing or improving. SWITCHDEV_ATTR_ID_PORT_PARENT_ID is broken, which
> is apparent when testing on the ZII devel board with multiple
> switches.
>
> Some of these patches are taken from a previous RFC patchset of IGMP
> support. Hence the v2 comments...

mlxsw and others return BR_FLOOD and BR_MCAST_FLOOD in
SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS_SUPPORT, is this something DSA needs
here?


Thanks,

        Vivien
