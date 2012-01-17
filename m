From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] smsc95xx: use usleep_range(), get rid out of
 jiffies
Date: Tue, 17 Jan 2012 10:48:25 -0500 (EST)
Message-ID: <20120117.104825.457549923860308778.davem@davemloft.net>
References: <1326804852-17742-1-git-send-email-dmitry.antipov@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, gregkh@suse.de,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linaro-dev@lists.linaro.org,
	patches@linaro.org
To: dmitry.antipov@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326804852-17742-1-git-send-email-dmitry.antipov@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Antipov <dmitry.antipov@linaro.org>
Date: Tue, 17 Jan 2012 16:54:12 +0400

> -/* Loop until the read is completed with timeout
> - * called with phy_mutex held */
> +/* Busy-wait loop until the read is completed, but
> +   no longer than 10ms. Called with phy_mutex held. */

Please:

	/* Write comments.
	 * Like this.
	 */
