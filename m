From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v3 11/12] net: dsa: mv88e6xxx: add G1 helper for
 ageing time
Date: Tue, 19 Jul 2016 20:58:31 +0200
Message-ID: <20160719185831.GI31103@lunn.ch>
References: <20160719004540.1066-1-vivien.didelot@savoirfairelinux.com>
 <20160719004540.1066-12-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160719004540.1066-12-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 18, 2016 at 08:45:39PM -0400, Vivien Didelot wrote:
> All Marvell switch chips from (88E6060 to 88E6390) have a ATU Control
> register containing bits 11:4 to configure an ATU Age Time quotient.
> 
> However the coefficient used to calculate the ATU Age Time vary with the
> models. E.g. 88E6060, 88E6352 and 88E6390 use respectively 16, 15 and
> 3.75 seconds.
> 
> Add a age_time_coeff to the info structure to handle this and a Global 1
> helper to set the default age time of 5 minutes in the setup code.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
