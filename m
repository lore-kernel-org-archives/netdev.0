From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [v5] net: emac: emac gigabit ethernet controller driver
Date: Wed, 15 Jun 2016 21:41:42 -0700 (PDT)
Message-ID: <20160615.214142.1092705919839921659.davem@davemloft.net>
References: <1465942955-22988-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, f.fainelli@gmail.com
To: timur@codeaurora.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1465942955-22988-1-git-send-email-timur@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Timur Tabi <timur@codeaurora.org>
Date: Tue, 14 Jun 2016 17:22:35 -0500

> +/* Free all descriptors of given receive queue */
> +static void emac_rx_q_free_descs(struct emac_adapter *adpt)
> +{
> +	struct emac_rx_queue *rx_q = &adpt->rx_q;
> +	struct device *dev = adpt->netdev->dev.parent;
> +	size_t size;
> +	int i;

Please always order local variable declarations from longest to shortest
line.

Audit your entire driver for this issue, thanks.
