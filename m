From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 3/7] net: dsa: add support for switchdev FDB
 objects
Date: Thu, 6 Aug 2015 16:04:32 +0200
Message-ID: <20150806140432.GC19896@lunn.ch>
References: <1438839848-505-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1438839848-505-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1438839848-505-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien

Thanks for splitting up the big patch. This it is much easier to
review now.

Is this patch git bisectable?

Clearly after this patch, but before all the other patches are in, we
will not be programming the hardware. The call into the driver is
removed here, but the replacement is added later. But is the EOPNOTSUP
enough that the system keeps working, by falling back to software?

The two driver APIs are very similar, the main difference being the
MAC address. Can you do the refactoring first, and then make the API
change. That means we can test each patch individually, and have
proper git bisectability.

Thanks
       Andrew
