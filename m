From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] msm: rmnet: msm rmnet smd virtual ethernet driver
Date: Wed, 15 Dec 2010 13:41:07 -0800
Message-ID: <20101215134107.0354c0c3@nehalam>
References: <1292437866-11652-1-git-send-email-nvishwan@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-msm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Brian Swetland <swetland@google.com>
To: Niranjana Vishwanathapura <nvishwan@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292437866-11652-1-git-send-email-nvishwan@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Dec 2010 10:31:06 -0800
Niranjana Vishwanathapura <nvishwan@codeaurora.org> wrote:

> +static struct net_device_stats *rmnet_get_stats(struct net_device *dev)
> +{
> +	struct rmnet_private *p = netdev_priv(dev);
> +	return &p->stats;
> +}
> +

Just use dev->stats and this function would no longer be needed.

-- 
