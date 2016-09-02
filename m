From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/3] net: dsa: mv88e6xxx: make global2 code
 optional
Date: Fri, 2 Sep 2016 18:11:48 +0200
Message-ID: <20160902161148.GK16864@lunn.ch>
References: <20160902120819.10773-1-vivien.didelot@savoirfairelinux.com>
 <20160902120819.10773-4-vivien.didelot@savoirfairelinux.com>
 <20160902145511.GH16864@lunn.ch>
 <87k2eugwcs.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87k2eugwcs.fsf@ketchup.mtl.sfl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Vivien

> What do you think?

I think the probe() needs to fail with a very obvious error message
saying you need to recompile your kernel with option XYZ enabled in
order to support this switch, when the optional stuff is not
optional...

	Andrew
