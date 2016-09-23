From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Alignment issues with freescale FEC driver
Date: Fri, 23 Sep 2016 20:13:01 +0200
Message-ID: <20160923181301.GD22965@lunn.ch>
References: <troy.kisky@boundarydevices.com>
 <02afb707-65de-5101-a79b-355929c4e00b@nelint.com>
 <CANn89iLb+QJu+MYh859oAAjcLCsKRpBbzVf43yOdq+HJVtZDpQ@mail.gmail.com>
 <5ee28ee0-cf0c-bdab-1271-f17755365c13@nelint.com>
 <0fe7a310-2d2f-4fca-d698-85d66122d91c@nelint.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>,
        Fugang Duan <fugang.duan@nxp.com>,
        Otavio Salvador <otavio@ossystems.com.br>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        rmk+kernel@arm.linux.org.uk, Simone <cjb.sw.nospam@gmail.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Eric Nelson <eric@nelint.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60651 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1034492AbcIWSNF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 14:13:05 -0400
Content-Disposition: inline
In-Reply-To: <0fe7a310-2d2f-4fca-d698-85d66122d91c@nelint.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Since the hardware requires longword alignment for its' DMA transfers,
> aligning the IP header will require a memcpy, right?

The vf610 FEC has an SHIFT16 bit in register ENETx_TACC, which inserts
two padding bits on transmit. ENETx_RACC has the same.

What about your hardware?

     Andrew
