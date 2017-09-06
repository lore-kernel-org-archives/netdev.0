From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 rfc 8/8] net: dsa: Fix SWITCHDEV_ATTR_ID_PORT_PARENT_ID
Date: Wed, 6 Sep 2017 18:29:33 +0200
Message-ID: <20170906162933.GD15315@lunn.ch>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch>
 <1504654510-31004-9-git-send-email-andrew@lunn.ch>
 <87d17351gn.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170906150825.GB15315@lunn.ch>
 <0D9EF30F-ED95-486E-91B0-E18D5E8689FE@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, jiri@resnulli.us,
        nikolay@cumulusnetworks.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58850 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753775AbdIFQ3g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 12:29:36 -0400
Content-Disposition: inline
In-Reply-To: <0D9EF30F-ED95-486E-91B0-E18D5E8689FE@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> >Yes, you are correct. I will change this.
> 

> A switch cluster should be tied to the same dsa_switch_tree though,
> can we use dst->tree as an unique identifier?

Yes, that is what Vivien was suggesting.

     Andrew
