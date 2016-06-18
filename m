From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v3 net-next v3 14/14] net: dsa: mv88e6xxx: add port base
 address to info
Date: Sat, 18 Jun 2016 22:38:03 +0200
Message-ID: <20160618203803.GI7172@lunn.ch>
References: <20160618000736.5598-1-vivien.didelot@savoirfairelinux.com>
 <20160618000736.5598-15-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Ben Dooks <ben.dooks@codethink.co.uk>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160618000736.5598-15-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 17, 2016 at 08:07:36PM -0400, Vivien Didelot wrote:
> The switch ID is located at address 0x3 of every Port Registers bank.
> 
> But not all Marvell switches have their Port Registers SMI Addresses
> starting at 0x10. 88E6060 starts at 0x8 and 88E6390 starts at 0x0.
> 
> Add this data in the info structure and use it in the detection code.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
