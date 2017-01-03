From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/3] net: dsa: restore HWMON support in dsa2
Date: Tue, 3 Jan 2017 21:09:14 +0100
Message-ID: <20170103200914.GB8765@lunn.ch>
References: <20170103181538.2593-1-vivien.didelot@savoirfairelinux.com>
 <20170103183352.GA30638@lunn.ch>
 <87ful0eylp.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <0a504cad-2f2c-fc6a-9965-5ae87be9dac4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>, cphealy@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>,
        John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0a504cad-2f2c-fc6a-9965-5ae87be9dac4@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Well, I agree with the regression part, but an argument could
> definitively be made that HWMON did not belong in the DSA layer in the
> first place, unless we were able to find some commonality between
> devices which AFAICT, we could not yet.

Florian, does SF2 or b53 have a temperature sensor?
John, does the qca8k have a temperature sensor?

If we do have a switch with a temperature sensor, making the HWMON
code available as a library for switch drivers to use makes sense.
However, if we move the Marvell code into the PHY driver, and there
are no other switches with temperature sensors, we should just remove
it.

	Andrew
