From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: forward unknown mc packets on mv88e6097
Date: Wed, 23 Nov 2016 12:52:52 -0500
Message-ID: <877f7uxevf.fsf@ketchup.i-did-not-set--mail-host-address--so-tickle-me>
References: <20161123165022.GD12698@gruene.netmodule.intranet> <20161123165440.4894-1-stefan.eichenberger@netmodule.com> <20161123165949.GB8760@lunn.ch> <20161123171441.GE12698@gruene.netmodule.intranet> <20161123174040.GE8760@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stefan Eichenberger <eichest@gmail.com>, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:35776 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932464AbcKWRwz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 12:52:55 -0500
In-Reply-To: <20161123174040.GE8760@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Andrew Lunn <andrew@lunn.ch> writes:

> And if you have a recent version of tcpdump, it will decode
> the header.

Since d729eb4, thanks to you Andrew ;-)

I move up the cleanup of ports setup in my priority list. The code is
quite cluttered at the moment and it's hard to read through it. We need
proper helpers for egress floods, (E)DSA setup, etc. like what is being
done for the other devices.

Thanks,

        Vivien
