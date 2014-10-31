From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 09/15] net: dsa: Add support for switch EEPROM access
Date: Fri, 31 Oct 2014 03:40:44 +0100
Message-ID: <20141031024044.GA4082@lunn.ch>
References: <1414604707-22407-1-git-send-email-linux@roeck-us.net>
 <1414604707-22407-10-git-send-email-linux@roeck-us.net>
 <20141030211131.GB32139@lunn.ch>
 <20141030223951.GA19489@roeck-us.net>
 <20141031010039.GA29492@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141031010039.GA29492@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> As suspected, ethtool will attempt to read a zero-length eeprom.
> 
> The following patch should solve the problem. Not sure if it is worth it,
> though, since this will change behavior for existing drivers.

Yes, it changes behaviour, but it does make it more consistent.

Probably it should be up to core network people to decide if this is
the write fix or leave it as is.

    Andrew
