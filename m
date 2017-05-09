From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Marvell phy errata origins?
Date: Tue, 9 May 2017 16:24:49 +0200
Message-ID: <20170509142449.GA19251@lunn.ch>
References: <59691a35-a89c-f9ca-c7b0-73134a737f4c@cisco.com>
 <20170418140450.GB13724@lunn.ch>
 <ffd12ac5-7501-0310-182f-1735c2da8165@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Andy Fleming <afleming@freescale.com>,
        Harini Katakam <harini.katakam@xilinx.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        HEMANT RAMDASI <hramdasi@cisco.com>,
        "Julius Hemanth Pitti -X (jpitti - MONTA VISTA SOFTWARE INC at Cisco)"
        <jpitti@cisco.com>
To: Daniel Walker <danielwa@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54608 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754223AbdEIOYz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 10:24:55 -0400
Content-Disposition: inline
In-Reply-To: <ffd12ac5-7501-0310-182f-1735c2da8165@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> According to Marvell this was errata for 88M1101 , and should not be
> applied to any other phy .. So we should be removing these lines and
> make a special aneg for 88M1101 then restore everything that doesn't
> need this back to the generic aneg,

Hi Daniel

Thanks for finding this out. Can you role a patch?

       Andrew
