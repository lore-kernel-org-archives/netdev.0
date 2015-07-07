From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 1/3] net: dsa: mv88e6xxx: add debugfs interface for VTU
Date: Tue, 7 Jul 2015 18:07:44 +0200
Message-ID: <20150707160744.GA13230@lunn.ch>
References: <1436148893-14379-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1436148893-14379-2-git-send-email-vivien.didelot@savoirfairelinux.com>
 <20150707020818.GB5540@lunn.ch>
 <1165322565.210276.1436284349938.JavaMail.zimbra@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	kernel <kernel@savoirfairelinux.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1165322565.210276.1436284349938.JavaMail.zimbra@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Indeed, I intentionally kept it as is, since the 88E6352 datasheet is not
> really clear about this. I see that the register 0x09 (called
> GLOBAL_VTU_DATA_8_11 in mv88e6xxx.h) only contains VID priority related bits in
> 15:12, in my case. As bits 11:0 are reserved, I suspect that the offsets of
> Member TagP7, Member TagP8 and Member TagP9 are respectively 0, 4 and 8 for
> you. Can you confirm? If so, I'll make that generic with these values.

Yes, the pattern continues for up to 11 ports, if you look at the DSDT
sources from Marvell. The mv88e6131.c driver has one device, the 6095,
with 11 ports.

     Thanks
          Andrew
