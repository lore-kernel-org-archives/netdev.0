From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next]alx: Atheros AR8131/AR8151/AR8152/AR8161
 Ethernet driver
Date: Wed, 19 Oct 2011 03:33:24 -0400 (EDT)
Message-ID: <20111019.033324.1233460304204609569.davem@davemloft.net>
References: <1319009213-20627-1-git-send-email-cloud.ren@atheros.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Luis.Rodriguez@Atheros.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: cloud.ren@Atheros.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319009213-20627-1-git-send-email-cloud.ren@atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <cloud.ren@Atheros.com>
Date: Wed, 19 Oct 2011 15:26:53 +0800

> +#define HW_PRINT(_klv, _fmt, _args...) \
> +	if (ALX_HW_MSG_LV_##_klv || ALX_HW_MSG_LV_ALL) {\
> +		printk(KERN_##_klv ALX_HW_MSG_PFX_NAME "%s: " _fmt, \
> +			__func__, ## _args); \
> +	}

Do not create your own network driver debugging facilities and macros
for logging messages, we have rich debugging and logging level
interfaces that network drivers can use exactly for this purpose.
