From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 03/14] net: dsa: mv88e6xxx: setup ATU Learn2All
Date: Fri, 10 Mar 2017 03:03:29 +0100
Message-ID: <20170310020329.GH22101@lunn.ch>
References: <20170309233324.18539-1-vivien.didelot@savoirfairelinux.com>
 <20170309233324.18539-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170309233324.18539-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 09, 2017 at 06:33:13PM -0500, Vivien Didelot wrote:
> Marvell switch chips which can be interconnected have an ATU Learn2All
> feature which allows chosen ports to also learn newly added addresses.
> 
> Enable this feature and mark the DSA links as so called "Message Ports".

Hi Vivien

I would of probably split this into two patches. One for adding
message ports, and one for refactoring the existing learn2all.

	Andrew
