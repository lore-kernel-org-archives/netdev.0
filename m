From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 09/12] net: bcmgenet: return EOPNOTSUPP for
 unknown ioctl commands
Date: Tue, 14 Mar 2017 11:04:54 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB052E@AcuExch.aculab.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
 <20170314004142.4746-10-opendmb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "robh+dt@kernel.org" <robh+dt@kernel.org>,
        "mark.rutland@arm.com" <mark.rutland@arm.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "rafal@milecki.pl" <rafal@milecki.pl>,
        "xow@google.com" <xow@google.com>,
        "joel@jms.id.au" <joel@jms.id.au>,
        "jon.mason@broadcom.com" <jon.mason@broadcom.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "pgynther@google.com" <pgynther@google.com>,
        "jaedon.shin@gmail.com" <jaedon.shin@gmail.com>
To: 'Doug Berger' <opendmb@gmail.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-10-opendmb@gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Doug Berger
> Sent: 14 March 2017 00:42
> This commit changes the ioctl handling behavior to return the
> EOPNOTSUPP error code instead of the EINVAL error code when an
> unknown ioctl command value is detected.
> 
> It also removes some redundant parsing of the ioctl command value
> and allows the SIOCSHWTSTAMP value to be handled.

A better description would seem to be:
Remove checks on ioctl command and just forward all ioctl requests
to phy_mii_ioctl().

I also thought the 'generic' response to an unknown ioctl command
was ENOTTY.

	David
