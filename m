From: Johan Hovold <johan@kernel.org>
Subject: [PATCH net 0/3] net: stmmac: dwmac-oxnas: fix leaks and simplify pm
Date: Mon,  2 Jan 2017 12:56:01 +0100
Message-ID: <20170102115604.32482-1-johan@kernel.org>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        Neil Armstrong <narmstrong@baylibre.com>,
        netdev@vger.kernel.org, linux-oxnas@lists.tuxfamily.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches fixes of-node and fixed-phydev leaks in the recently added
dwmac-oxnas driver, and ultimately switches over to using the generic pm
implementation as the required callbacks are now in place.

Note that this series has only been compile tested.

Johan


Johan Hovold (3):
  net: stmmac: dwmac-oxnas: fix of-node leak
  net: stmmac: dwmac-oxnas: fix fixed-link-phydev leaks
  net: stmmac: dwmac-oxnas: use generic pm implementation

 drivers/net/ethernet/stmicro/stmmac/dwmac-oxnas.c | 89 +++++++++--------------
 1 file changed, 33 insertions(+), 56 deletions(-)

-- 
2.10.2
