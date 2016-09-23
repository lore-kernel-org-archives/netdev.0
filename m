From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: Alignment issues with freescale FEC driver
Date: Fri, 23 Sep 2016 19:30:11 +0100
Message-ID: <20160923183010.GB1041@n2100.armlinux.org.uk>
References: <troy.kisky@boundarydevices.com>
 <02afb707-65de-5101-a79b-355929c4e00b@nelint.com>
 <CANn89iLb+QJu+MYh859oAAjcLCsKRpBbzVf43yOdq+HJVtZDpQ@mail.gmail.com>
 <5ee28ee0-cf0c-bdab-1271-f17755365c13@nelint.com>
 <0fe7a310-2d2f-4fca-d698-85d66122d91c@nelint.com>
 <20160923181301.GD22965@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Nelson <eric@nelint.com>, Eric Dumazet <edumazet@google.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        Otavio Salvador <otavio@ossystems.com.br>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Simone <cjb.sw.nospam@gmail.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:53262 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965572AbcIWSa3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 14:30:29 -0400
Content-Disposition: inline
In-Reply-To: <20160923181301.GD22965@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2016 at 08:13:01PM +0200, Andrew Lunn wrote:
> > Since the hardware requires longword alignment for its' DMA transfers,
> > aligning the IP header will require a memcpy, right?
> 
> The vf610 FEC has an SHIFT16 bit in register ENETx_TACC, which inserts
> two padding bits on transmit. ENETx_RACC has the same.
> 
> What about your hardware?

The iMX6 FEC also has that ability - as part of my FEC patch stack from
ages ago, I implemented support for it.

  "net:fec: implement almost zero-copy receive path"

in my public fec-testing branch.

That patch stack is sadly now totally dead and I've no interest in
reviving it myself.  There was some interest from others in taking my
patch stack over, but that went quiet.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
