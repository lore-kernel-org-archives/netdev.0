From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/9] net: dsa: mv88e6xxx: rework Switch MAC
 setter
Date: Thu, 7 Jul 2016 15:52:53 +0200
Message-ID: <20160707135253.GO19800@lunn.ch>
References: <20160707125758.1547-1-vivien.didelot@savoirfairelinux.com>
 <20160707125758.1547-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160707125758.1547-7-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Also, note that this indirect access is a single-register which doesn't
> require to wait for the operation to complete (like Switch MAC, Trunk
> Mapping, etc.), in contrary to multi-registers indirect accesses with
> several busy operations (like ATU, VTU, etc.).

Hi Vivien

Are you sure about this? The DSDT polls bit 15 of the register.

    Andrew
