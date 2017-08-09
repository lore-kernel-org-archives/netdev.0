From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 3/4] net-next: tag_mtk: add flow_dissect callback to the
 ops struct
Date: Wed, 9 Aug 2017 15:54:12 +0200
Message-ID: <20170809135412.GE30723@lunn.ch>
References: <20170809124119.24320-1-john@phrozen.org>
 <20170809124119.24320-4-john@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Sean Wang <sean.wang@mediatek.com>, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
        Muciri Gatimu <muciri@openmesh.com>,
        Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>
To: John Crispin <john@phrozen.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170809124119.24320-4-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2017 at 02:41:18PM +0200, John Crispin wrote:
> The MT7530 inserts the 4 magic header in between the 802.3 address and
> protocol field. The patch implements the callback that can be called by
> the flow dissector to figure out the real protocol and offset of the
> network header. With this patch applied we can properly parse the packet
> and thus make hashing function properly.
> 
> Signed-off-by: Muciri Gatimu <muciri@openmesh.com>
> Signed-off-by: Shashidhar Lakkavalli <shashidhar.lakkavalli@openmesh.com>
> Signed-off-by: John Crispin <john@phrozen.org>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
