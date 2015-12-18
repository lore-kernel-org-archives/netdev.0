From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: commit e34d65696d2e broke stmmac ethernet on socfpga
Date: Fri, 18 Dec 2015 11:45:09 -0600
Message-ID: <56744625.8040209@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <robh@kernel.org>,
	<netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	<peppe.cavallaro@st.com>
To: <preid@electromag.com.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

It appears that commit e34d65696d2e 'stmmac: create of compatible mdio
bus for
stmmac driver' is causing this error on the SoCFPGA platform:

[    1.767246] libphy: PHY stmmac-0:ffffffff not found
[    1.772106] eth0: Could not attach to PHY
[    1.776129] stmmac_open: Cannot attach to PHY (error: -19)
[    1.781590] IP-Config: Failed to open eth0
[    1.785681] IP-Config: No network devices available

Doing a revert of this commit fixes the issue. Will try to debug further.

Thanks,
Dinh
