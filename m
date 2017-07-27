From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 06/10] net: dsa: lan9303: added sysfs node
 swe_bcst_throt
Date: Thu, 27 Jul 2017 15:26:25 +0200
Message-ID: <20170727132625.GA18666@lunn.ch>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-7-privat@egil-hjelmeland.no>
 <20170726171423.GQ12049@lunn.ch>
 <f0105583-9363-e8a6-79fc-675bb8dbadcf@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: corbet@lwn.net, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f0105583-9363-e8a6-79fc-675bb8dbadcf@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Yes, this setting can be used to reduce effect of broadcast storms.

So one way to solve this is to teach the software bridge about
broadcast storm control. Put some rate limiting into its broadcast
flood handling. Then add a switchdev call which passes this down into
the switch.

Or look at doing it via TC. It is just a filter selecting broadcast
traffic and applying some shaping, which is what TC is all about.

Generic solutions which can be used by all switches are likely to be
accepted.

	Andrew
