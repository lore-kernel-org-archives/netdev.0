From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 3/6] net: dsa: mv88e6xxx: write MAC outside
 of ATU Get Next code
Date: Tue, 13 Oct 2015 10:35:37 -0700
Message-ID: <561D40E9.8030602@gmail.com>
References: <1444754783-26975-1-git-send-email-vivien.didelot@savoirfairelinux.com> <1444754783-26975-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, Andrew Lunn <andrew@lunn.ch>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444754783-26975-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/10/15 09:46, Vivien Didelot wrote:
> There is no need to write the MAC address before every Get Next
> operation, since ATU MAC registers are not cleared between calls.
> 
> Move the _mv88e6xxx_atu_mac_write call outside of _mv88e6xxx_atu_getnext
> so future code could call ATU Get Next multiple times and save a few
> register access.

Missing SoB tag here.
-- 
Florian
