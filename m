From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next RFC 0/9] net: dsa: PTP timestamping for mv88e6xxx
Date: Thu, 28 Sep 2017 19:36:29 +0200
Message-ID: <20170928173629.GD14940@lunn.ch>
References: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Richard Cochran <richardcochran@gmail.com>,
        Erik Hons <erik.hons@ni.com>
To: Brandon Streiff <brandon.streiff@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1506612341-18061-1-git-send-email-brandon.streiff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> - Patch #3: The GPIO config support is handled in a very simple manner.
>   I suspect a longer term goal would be to use pinctrl here.

I assume ptp already has the core code to use pinctrl and Linux
standard GPIOs? What does the device tree binding look like? How do
you specify the GPIOs to use?

What we want to avoid is defining an ABI now, otherwise it is going to
be hard to swap to pinctrl later.

> - Patch #6: the dsa_switch pointer and port index is plumbed from
>   dsa_device_ops::rcv so that we can call the correct port_rxtstamp
>   method. This involved instrumenting all of the *_tag_rcv functions in
>   a way that's kind of a kludge and that I'm not terribly happy with.

Yes, this is ugly. I will see if i can find a better way to do
this. 

      Andrew
