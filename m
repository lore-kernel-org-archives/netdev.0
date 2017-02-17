From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 4/6] net: dsa: mv88e6xxx: move VTU code to
 its own file
Date: Fri, 17 Feb 2017 22:46:10 +0100
Message-ID: <20170217214610.GJ6096@lunn.ch>
References: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
 <20170217150531.2181-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170217150531.2181-5-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 17, 2017 at 10:05:29AM -0500, Vivien Didelot wrote:
> Move the Global (1) VTU related code to its own file.
> 
> Use this opportunity to provide a cleaner API for the VTU, by renaming a
> few underscore prefixed functions, split the data member of the
> mv88e6xxx_vtu_entry structure into membership (for 802.1q) and port
> state (for 802.1s) members, and add a mv88e6xxx_has_vtu() helper.

Again, seperate move from cleanups please.

       Andrew
