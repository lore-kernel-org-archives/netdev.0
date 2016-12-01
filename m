From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Thu, 1 Dec 2016 18:31:00 +0100
Message-ID: <20161201173100.GG21887@lunn.ch>
References: <1480495831.3563.135.camel@infinera.com>
 <584054C4.1010809@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Roger Quadros <rogerq@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36521 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934095AbcLARbD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 12:31:03 -0500
Content-Disposition: inline
In-Reply-To: <584054C4.1010809@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Murali 

> 2. Switch mode where it implements a simple Ethernet switch. Currently
>    it doesn't have address learning capability, but in future it
>    can.

If it does not have address learning capabilities, does it act like a
plain old hub? What comes in one port goes out all others?

Or can you do the learning in software on the host and program tables,
which the hardware then uses?

> 3. Switch with HSR/PRP offload where it provides HSR/PRP protocol
>    support and cut through switch.
> 
> So a device need to function in one of the modes. A a regular Ethernet
> driver that provides two network devices, one per port, and switchdev
> for each physical port (in switch mode) will look ideal in this case.

Yes, this seems the right model to use.

     Andrew
