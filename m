From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] mdio: mux: fix parsing mux registers outside of the
 PHY address range
Date: Mon, 10 Jul 2017 16:37:31 +0200
Message-ID: <20170710143731.GE21118@lunn.ch>
References: <20170710123523.6625-1-martin.blumenstingl@googlemail.com>
 <20170710125652.GG1616@lunn.ch>
 <CAC3K-4p0gidfh1U+_o3i7bwCgQo1QtNb7D+MXwYa+X_-9sFhrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        linux-amlogic@lists.infradead.org
To: Jon Mason <jon.mason@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49542 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753833AbdGJOhg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 10 Jul 2017 10:37:36 -0400
Content-Disposition: inline
In-Reply-To: <CAC3K-4p0gidfh1U+_o3i7bwCgQo1QtNb7D+MXwYa+X_-9sFhrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> To be clear, are you suggesting that we add an additional property to
> of_mdio_parse_addr() that specifies the limit to check against, or
> remove the check and add it to each additional caller?

Hi Jon

Probably the simplest is to add an extra parameter to mdio_mux_init()
which is the maximum allowed reg value.

We should not touch of_mdio_parse_addr(). reg is not an mdio
address. It is a count of gpios, or a value to be poked into an
register.

      Andrew
