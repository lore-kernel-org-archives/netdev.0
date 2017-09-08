From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 1/6] The file ksz_common.c will be used by other KSZ
 switch drivers.
Date: Fri, 8 Sep 2017 02:40:00 +0200
Message-ID: <20170908004000.GA2746@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD411218C4@CHN-SV-EXMX02.mchp-main.com>
 <93AF473E2DA327428DE3D46B72B1E9FD411219FF@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD411219FF@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 07, 2017 at 09:08:58PM +0000, Tristram.Ha@microchip.com wrote:
> From: Tristram Ha <Tristram.Ha@microchip.com>

Hi Tristram

Another process thing you are missing. Patch subject should follow a
pattern:

git log --oneline drivers/net/dsa/mv88e6xxx
bb0a2675f72b net: dsa: mv88e6xxx: Enable CMODE config support for 6390X
b3e05aa12319 net: dsa: mv88e6xxx: add a multi_chip info flag
68b8f60cf70d net: dsa: mv88e6xxx: add Energy Detect ops
9069c13a4867 net: dsa: mv88e6xxx: add a global2_addr info flag
9e907d739cc3 net: dsa: mv88e6xxx: add POT operation
a2a05db8a5ed net: dsa: mv88e6xxx: add POT flag to 88E6390
51c901a77562 net: dsa: mv88e6xxx: distinguish Global 2 Rsvd2CPU
d6c5e6aff50c net: dsa: mv88e6xxx: add number of Global 2 IRQs
74e60241ce14 net: dsa: mv88e6xxx: remove 88E6185 G2 interrupt
2466f64ae4e9 net: dsa: mv88e6xxx: remove unused capabilities

Please set the subject line in your patches similarly.

       Andrew
