From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: DSA support for Micrel KSZ8895
Date: Wed, 23 Aug 2017 14:42:07 +0200
Message-ID: <20170823124207.GB28612@lunn.ch>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170823090941.GA27570@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Woojung.Huh@microchip.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170823090941.GA27570@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Any ideas how to do the work in a way to minimize code duplication are
> welcome...

A lot depends on how much duplication there is. mv88e6xxx uses a set
of function points per chip variant. Another option is to put the
common code into a library, and have two drivers. Or if it is the same
registers, but at different locations, you can add a translation
function, which is what i think the b53 driver does.

	  Andrew
