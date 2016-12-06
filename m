From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net:mv88e6xxx: dispose irq mapping
Date: Tue, 6 Dec 2016 16:08:56 +0100
Message-ID: <20161206150856.GG26615@lunn.ch>
References: <1481018743-27208-1-git-send-email-volodymyr.bendiuga@westermo.se>
 <20161206141923.GB26615@lunn.ch>
 <7717215e-dddd-14af-196f-e638b5c60649@westermo.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org
To: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44175 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751443AbcLFPI7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 10:08:59 -0500
Content-Disposition: inline
In-Reply-To: <7717215e-dddd-14af-196f-e638b5c60649@westermo.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 06, 2016 at 04:00:27PM +0100, Volodymyr Bendiuga wrote:
> Hi Andrew,
> 
> thanks for you comments and time taken to review. I will make a new
> 
> version which will indicate net-next tree.
> 
> About mv88e6xxx_remove(), this function will not be called

Correct, which is why i said:

> and the error path of mv88e6xxx_probe().

which will be called on EPRODE_DEFFER. 

> irq_dispose_mapping() is also called in mv88e6xxx_g2_irq_free(), so
> I put it in a similar

The mapping for chip->device_irq is made in mv88e6xxx_g2_irq_setup(),
so the disposal of the mapping logically goes in
mv88e6xxx_g2_irq_free().

	Andrew
