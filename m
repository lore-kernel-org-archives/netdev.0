From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 0/3] net: dsa: voidify STP setter and
 FDB/VLAN add ops
Date: Wed, 6 Apr 2016 18:19:45 +0200
Message-ID: <20160406161945.GA13088@lunn.ch>
References: <1459958105-1090-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1459958105-1090-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 06, 2016 at 11:55:02AM -0400, Vivien Didelot wrote:
> Neither the DSA layer nor the bridge code (see br_set_state) really care
> about eventual errors from STP state setters, so make it void.
> 
> The DSA layer separates the prepare and commit phases of switchdev in
> two different functions. Logical errors must not happen in commit
> routines, so make them void.

Looks good.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew
