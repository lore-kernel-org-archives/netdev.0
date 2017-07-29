From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: thunderx: Fix BGX transmit stall due to underflow
Date: Sat, 29 Jul 2017 14:18:13 -0700 (PDT)
Message-ID: <20170729.141813.2129692875257358096.davem@davemloft.net>
References: <1501140184-25625-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501140184-25625-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sunil.kovvuri@gmail.com
Date: Thu, 27 Jul 2017 12:53:04 +0530

> From: Sunil Goutham <sgoutham@cavium.com>
> 
> For SGMII/RGMII/QSGMII interfaces when physical link goes down
> while traffic is high is resulting in underflow condition being set
> on that specific BGX's LMAC. Which assets a backpresure and VNIC stops
> transmitting packets.
> 
> This is due to BGX being disabled in link status change callback while
> packet is in transit. This patch fixes this issue by not disabling BGX
> but instead just disables packet Rx and Tx.
> 
> Signed-off-by: Sunil Goutham <sgoutham@cavium.com>

Applied.
