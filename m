From: Kevin Smith <kevin.smith@elecsyscorp.com>
Subject: Re: [PATCH net-next 7/9] net: dsa: mv88e6xxx: restore VLANTable map
 control
Date: Fri, 26 Feb 2016 22:12:28 +0000
Message-ID: <56D0CDCD.2040806@elecsyscorp.com>
References: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1456510568-13679-8-git-send-email-vivien.didelot@savoirfairelinux.com>
 <56D0B964.4090002@elecsyscorp.com> <20160226210419.GA1560@lunn.ch>
 <87d1rj6tlo.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Russell King <rmk+kernel@arm.linux.org.uk>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d1rj6tlo.fsf@ketchup.mtl.sfl>
Content-Language: en-US
Content-ID: <5EBAF73B792B1640B3CB60A9D2B96579@dciincorporated.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien, Andrew,

On 02/26/2016 03:37 PM, Vivien Didelot wrote:
> Here, 5 is the CPU port and 6 is a DSA port.
>
> After joining ports 0, 1, 2 in the same bridge, we end up with:
>
> Port  0  1  2  3  4  5  6
>    0   -  *  *  -  -  *  *
>    1   *  -  *  -  -  *  *
>    2   *  *  -  -  -  *  *
>    3   -  -  -  -  -  *  *
>    4   -  -  -  -  -  *  *
>    5   *  *  *  *  *  -  *
>    6   *  *  *  *  *  *  -
The case I am concerned about is if the switch connected over DSA in 
this example has a WAN port on it, which can legitimately route to the 
CPU on port 5 but should not route to the LAN ports 0, 1, and 2.  Does 
this VLAN allow direct communication between the WAN and LAN?  Or is 
this prevented by DSA or some other mechanism?

Thanks,
Kevin
