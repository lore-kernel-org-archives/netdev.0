From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next v2 05/12] net: dsa: mv88e6xxx: add cap for
 MGMT Enables bits
Date: Mon, 18 Jul 2016 21:38:46 +0200
Message-ID: <20160718193846.GM31103@lunn.ch>
References: <20160718184628.13103-1-vivien.didelot@savoirfairelinux.com>
 <20160718184628.13103-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44959 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751705AbcGRTit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jul 2016 15:38:49 -0400
Content-Disposition: inline
In-Reply-To: <20160718184628.13103-6-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 18, 2016 at 02:46:21PM -0400, Vivien Didelot wrote:
> Some switches provide a Rsvd2CPU mechanism used to choose which of the
> 16 reserved multicast destination addresses matching 01:80:c2:00:00:0x
> should be considered as MGMT and thus forwarded to the CPU port.
> 
> Other switches extend this mechanism to also configure as MGMT the
> additional 16 reserved multicast addresses matching 01:80:c2:00:00:2x.
> 
> This mechanism is exposed via two registers in Global 2, and an Rsvd2CPU
> enable bit in the management register.
> 
> Newer chip (such as 88E6390) has replaced these registers with a new
> indirect MGMT mechanism in Global 1.
> 
> The patch adds two MV88E6XXX_FLAG_G2_MGMT_EN_{0,2}X flags to describe
> the presence of these Global 2 registers. If 88E6390 support is added, a
> MV88E6XXX_FLAG_G1_MGMT_CTRL flag will be needed to setup Rsvd2CPU.
> 
> Note: all switches still support in parallel the ATU Load operation with
> an MGMT Entry State to forward such frames in a less convenient way.
> 
> net: dsa: mv88e6xxx: add cap for MGMT Enable 2x

We seem to have an extra subject line here?

> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
