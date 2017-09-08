From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 3/6] The file ksz_common.c contains common code
 shared by all KSZ switch drivers
Date: Fri, 8 Sep 2017 03:12:43 +0200
Message-ID: <20170908011243.GC2746@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218DC@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41121A0D@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121A0D@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tristram

You patches are so badly mangled that they won't apply. So i'm
guessing a bit here...

What i think is you can do this in three patches:

1) Straight rename of ksz_common.c to ksz9477.c. Makefile changes to
   fit, no code changes.
2) Move common code back into ksz_common.c. Makefile changes to fit.
3) ksz9477.c prefix name changes

It looks like there is not too much common code in ksz_common.c. So
doing it this way makes the changes minimal, and things compile at
each stage.

Remember to use -M with git format-patch.

	 Andrew
