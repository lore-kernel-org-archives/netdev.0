From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Centralizing support for TCAM?
Date: Fri, 2 Sep 2016 21:02:03 +0200
Message-ID: <20160902190203.GS16864@lunn.ch>
References: <57d4a2db-ca3b-909a-073a-52ecceb428f2@gmail.com>
 <b8323295-e3eb-48ca-7c82-ff40d222a743@gmail.com>
 <57C9C9BE.6040407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        jiri@mellanox.com, idosh@mellanox.com, john.fastabend@intel.com,
        ast@kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        ecree@solarflare.com, vivien.didelot@savoirfairelinux.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34225 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754145AbcIBTCM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Sep 2016 15:02:12 -0400
Content-Disposition: inline
In-Reply-To: <57C9C9BE.6040407@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I need to get reasonable operations per second on the TCAM tables.
> Reasonable for me being somewhere in the 50k to 100k add/del/update
> commands per second. I'm hesitant to create more abstractions then
> are actually needed.

Hi John

That is an interesting requirement. Could you explain why?

The Marvell TCAM is accessed using MDIO. Maybe it can do 50
add/del/updates per second. For a WiFi access point, or cable modem,
even 50 per second seems ample, they get set at boot and never
changed.

	Andrew
