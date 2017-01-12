From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Correct method for initializing Pause and Asymmetrical Pause
 support in phy drivers
Date: Thu, 12 Jan 2017 16:35:35 +0100
Message-ID: <20170112153535.GA10203@lunn.ch>
References: <CAMqDo0XxvtjD+uJQeHJuSyN71zEEa5AB9YE1CUYK8wq2NGeAbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marc Bertola <marc.bertola@prolucid.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58481 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751113AbdALQK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 11:10:26 -0500
Content-Disposition: inline
In-Reply-To: <CAMqDo0XxvtjD+uJQeHJuSyN71zEEa5AB9YE1CUYK8wq2NGeAbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 12, 2017 at 10:21:29AM -0500, Marc Bertola wrote:
> Hello netdev list,
> 
> I am currently investigating a problem related to Ethernet
> auto-negotiation of Pause and Asymmetrical Pause capabilities.

Hi Marc

Have you read:

commit 2fa3e25b454e267d8f55ee19c27be540495463e7
Author: Florian Fainelli <f.fainelli@gmail.com>
Date:   Sun Nov 27 18:45:13 2016 -0800

    Documentation: net: phy: Add a paragraph about pause frames/flow control
    
    Describe that the Ethernet MAC controller is ultimately responsible for
    dealing with proper pause frames/flow control advertisement and
    enabling, and that it is therefore allowed to have it change
    phydev->supported/advertising with SUPPORTED_Pause and
    SUPPORTED_AsymPause.
    
    Reviewed-by: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
    Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

    Andrew
