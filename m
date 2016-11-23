From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: dsa: mv88e6xxx: forward unknown mc packets on
 mv88e6097
Date: Wed, 23 Nov 2016 17:59:49 +0100
Message-ID: <20161123165949.GB8760@lunn.ch>
References: <20161123165022.GD12698@gruene.netmodule.intranet>
 <20161123165440.4894-1-stefan.eichenberger@netmodule.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org,
        Stefan Eichenberger <stefan.eichenberger@netmodule.com>
To: Stefan Eichenberger <eichest@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50029 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933142AbcKWQ7v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 11:59:51 -0500
Content-Disposition: inline
In-Reply-To: <20161123165440.4894-1-stefan.eichenberger@netmodule.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2016 at 05:54:40PM +0100, Stefan Eichenberger wrote:
> Packets with unknown destination addresses are not forwarded to the cpu
> port on mv88e6097 based switches (e.g. MV88E6097) at the moment. This
> commit enables PORT_CONTROL_FORWARD_UNKNOWN_MC for this family.

Please try adding MV88E6XXX_FLAG_EDSA to
MV88E6XXX_FLAGS_FAMILY_6097. That is the better fix if it works.

     Andrew
