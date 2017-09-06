From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 rfc 8/8] net: dsa: Fix SWITCHDEV_ATTR_ID_PORT_PARENT_ID
Date: Wed, 6 Sep 2017 17:08:25 +0200
Message-ID: <20170906150825.GB15315@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <1504654510-31004-9-git-send-email-andrew@lunn.ch>
 <87d17351gn.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, jiri@resnulli.us,
        nikolay@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58749 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932657AbdIFPI0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 11:08:26 -0400
Content-Disposition: inline
In-Reply-To: <87d17351gn.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Use the MAC address of the master interface as the parent ID. This is
> > the same for all switches in a cluster, and should be unique if there
> > are multiple clusters.
> 
> That is not correct. Support for multiple CPU ports is coming and in
> this case, you can have two CPU host interfaces wired to two switch
> ports of the same tree. So two different master MAC addresses.

Yes, you are correct. I will change this.

     Andrew
