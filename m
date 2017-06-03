From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: phy: smsc: Implement PHY statistics
Date: Sat, 3 Jun 2017 02:52:43 +0200
Message-ID: <20170603005243.GA3243@lunn.ch>
References: <1496438670-30829-1-git-send-email-andrew@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AA9CB9@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        cphealy@gmail.com, nikita.yoush@cogentembedded.com,
        netdev@vger.kernel.org
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35162 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751061AbdFCAwx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Jun 2017 20:52:53 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40AA9CB9@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Woojung

> Just cosmetic thing.
> How about aligning with other members in structure like

Yes, i can do that. v2 tomorrow sometime.

> > +	.get_sset_count = smsc_get_sset_count,
> > +	.get_strings     = smsc_get_strings,
> > +	.get_stats        = smsc_get_stats,
> 
> Reviewed-By: Woojung Huh <Woojung.Huh@microchip.com>

Thanks.

Can you confirm the LAN911x Internal PHY don't have this. The register
is not listed in the switch datasheet.

Thanks
	Andrew
