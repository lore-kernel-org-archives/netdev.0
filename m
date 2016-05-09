From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 00/21] net: dsa: mv88e6xxx: turn into
 monolithic driver
Date: Mon, 9 May 2016 19:56:47 +0200
Message-ID: <20160509175647.GE10508@lunn.ch>
References: <1462814578-6249-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60314 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750941AbcEIR4v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 13:56:51 -0400
Content-Disposition: inline
In-Reply-To: <1462814578-6249-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 09, 2016 at 01:22:37PM -0400, Vivien Didelot wrote:
> This patchset merges all mv88e6* drivers supported by the shared
> mv88e6xxx code into a single mv88e6xxx DSA switch driver.
> 
> Some flags are added to describe the capabilities of a switch model,
> such as the presence of a PPU, EEPROM, some old or new registers, etc.
> 
> First these flags are used to conditionally support the same set of
> functions in every driver, then specific driver files are removed in
> favor of the common mv88e6xxx driver.
> 
> Only the merge of driver specific setup code assumes a few differences.
> If these differences such as frames priorities are really needed for
> some models, they can easily be brought back in a future patch.
> 
> Some inconsistencies might show up, such as the need for
> MV88E6XXX_FLAG_PPU and MV88E6XXX_FLAG_PPU_ACTIVE flags. But this
> patchset does not aim to fix them yet. A future patch can do that if
> they end up being unwanted.
> 
> The patchset has been tested on interconnected 88E6352 and 88E6185.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

I also tested v1, so

Tested-by: Andrew Lunn <andrew@lunn.ch>

Thanks
	Andrew
