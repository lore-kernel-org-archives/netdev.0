From: Romain Perier <romain.perier@gmail.com>
Subject: Re: commit e34d65696d2e broke stmmac ethernet on socfpga
Date: Fri, 1 Jan 2016 09:49:21 +0100
Message-ID: <CABgxDo+uTgYVYE-E6gQCoeWaeV=GKZVw-99JEHChDr3QAs9TkA@mail.gmail.com>
References: <56744625.8040209@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: preid@electromag.com.au, "David S. Miller" <davem@davemloft.net>,
	robh <robh@kernel.org>, netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	peppe.cavallaro@st.com
To: Dinh Nguyen <dinguyen@opensource.altera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56744625.8040209@opensource.altera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Same here on rockchip.
See "[PATCH] stmmac: Don't exit mdio registration when mdio subnode is
not found in the DTS"

Regards,
Romain

2015-12-18 18:45 GMT+01:00 Dinh Nguyen <dinguyen@opensource.altera.com>:
> Hi,
>
> It appears that commit e34d65696d2e 'stmmac: create of compatible mdio
> bus for
> stmmac driver' is causing this error on the SoCFPGA platform:
>
> [    1.767246] libphy: PHY stmmac-0:ffffffff not found
> [    1.772106] eth0: Could not attach to PHY
> [    1.776129] stmmac_open: Cannot attach to PHY (error: -19)
> [    1.781590] IP-Config: Failed to open eth0
> [    1.785681] IP-Config: No network devices available
>
> Doing a revert of this commit fixes the issue. Will try to debug further.
>
> Thanks,
> Dinh
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
