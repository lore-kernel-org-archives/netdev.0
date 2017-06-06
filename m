From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: fix 6085 frame mode
 masking
Date: Tue, 06 Jun 2017 16:04:48 -0400 (EDT)
Message-ID: <20170606.160448.1263511411241760892.davem@davemloft.net>
References: <20170605221716.32235-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170605221716.32235-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon,  5 Jun 2017 18:17:16 -0400

> The register bits used for the frame mode were masked with DSA (0x1)
> instead of the mask value (0x3) in the 6085 implementation of
> port_set_frame_mode. Fix this.
> 
> Fixes: 56995cbc3540 ("net: dsa: mv88e6xxx: Refactor CPU and DSA port setup")
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks Vivien.
