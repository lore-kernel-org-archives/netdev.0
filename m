From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/6] Fixes for the MV88e6xxx interrupt code
Date: Wed, 16 Nov 2016 20:45:25 +0100
Message-ID: <20161116194525.GB1087@lunn.ch>
References: <1479257816-7496-1-git-send-email-andrew@lunn.ch>
 <20161116.142102.1586244273660874282.davem@davemloft.net>
 <20161116.142916.1432429487379929901.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42244 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932247AbcKPTpe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 14:45:34 -0500
Content-Disposition: inline
In-Reply-To: <20161116.142916.1432429487379929901.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Take a look at how the 'device_irq' local variable is used in
> mv88e6xxx_g2_irq_setup.  You assign it to 'err' in an error
> path before it is ever set to anything.
> 
> I think you meant to use the structure's 'device_irq' member
> instead.

Hi David

Agreed. Thanks for the review.

	Andrew
