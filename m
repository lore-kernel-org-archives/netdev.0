From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 06/10] net: dsa: lan9303: added sysfs node
 swe_bcst_throt
Date: Wed, 26 Jul 2017 19:14:23 +0200
Message-ID: <20170726171423.GQ12049@lunn.ch>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
 <20170725161553.30147-7-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: corbet@lwn.net, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170725161553.30147-7-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 25, 2017 at 06:15:49PM +0200, Egil Hjelmeland wrote:
> Allowing per-port access to Switch Engine Broadcast Throttling Register

Hi Egil

In general, we are against using sysfs. If there is a generic
mechanism, that applies for all sorts of network interfaces, it should
be used instead of sysfs.

Is this intended to reduce the effect of broadcast storms?

   Andrew
