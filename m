From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next v2 3/6] net: dsa: mv88e6xxx: write MAC outside
 of ATU Get Next code
Date: Tue, 13 Oct 2015 14:11:14 -0400
Message-ID: <20151013181114.GA29391@ketchup.mtl.sfl>
References: <1444754783-26975-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1444754783-26975-4-git-send-email-vivien.didelot@savoirfairelinux.com>
 <561D40E9.8030602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <561D40E9.8030602@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Oct. Tuesday 13 (42) 10:35 AM, Florian Fainelli wrote:
> On 13/10/15 09:46, Vivien Didelot wrote:
> > There is no need to write the MAC address before every Get Next
> > operation, since ATU MAC registers are not cleared between calls.
> > 
> > Move the _mv88e6xxx_atu_mac_write call outside of _mv88e6xxx_atu_getnext
> > so future code could call ATU Get Next multiple times and save a few
> > register access.
> 
> Missing SoB tag here.

Damn, good catch. Can I add it in reply to the patch, or should I send a
v3?

Thanks,
-v
