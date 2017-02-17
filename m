From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 3/6] net: dsa: mv88e6xxx: add support for
 6390 ATU Move
Date: Fri, 17 Feb 2017 22:38:02 +0100
Message-ID: <20170217213802.GI6096@lunn.ch>
References: <20170217150531.2181-1-vivien.didelot@savoirfairelinux.com>
 <20170217150531.2181-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170217150531.2181-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 17, 2017 at 10:05:28AM -0500, Vivien Didelot wrote:
> The 6390 family of Marvell chips uses 5 bits to describe the ToPort and
> FromPort values of PortVec in the ATU Move operation, while older
> switches use 0xf.

Hi Vivien

Since you say 5 bits for 6390, it would be better to say 4 bits for
older switches.

Otherwise:

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
