From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [ISSUE: mv88e6xxx]: Down/Up link and not forwarding
Date: Tue, 4 Oct 2016 22:28:22 +0200
Message-ID: <20161004202822.GC22841@lunn.ch>
References: <8e5e36d7-7618-2a4e-6aba-e65e41662d47@aoifes.com>
 <40e73820-6e67-5cde-b492-bfbcba64caeb@aoifes.com>
 <19A0FE92-E4DB-49EB-AF4C-30A73DFED7E9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jose Antonio Delgado Alfonso <jose.delgado@aoifes.com>,
        netdev@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38852 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752439AbcJDU20 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Oct 2016 16:28:26 -0400
Content-Disposition: inline
In-Reply-To: <19A0FE92-E4DB-49EB-AF4C-30A73DFED7E9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >The main difference is GLOBAL2 5th register. When the unit is just
> >initialized, the driver sets this register to 00ff, however, when
> >the issue happens, its value is c12f.

You might want to hack the MDIO driver and get it to trap writes to
this register and give you a call stack.

     Andrew
