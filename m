From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] hv_netvsc: Set vRSS with num_chn in RNDIS
 filter
Date: Wed, 12 Aug 2015 14:45:49 -0700 (PDT)
Message-ID: <20150812.144549.1239580161501384675.davem@davemloft.net>
References: <1439338472-21361-1-git-send-email-andschwa@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: haiyangz@microsoft.com, kys@microsoft.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: andschwa@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439338472-21361-1-git-send-email-andschwa@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Schwartzmeyer <andschwa@microsoft.com>
Date: Tue, 11 Aug 2015 17:14:31 -0700

> Uses device_info->num_chn to pass user provided number of vRSS
> queues (from ethtool --set-channels) to rndis_filter_device_add. If
> nonzero and less than the maximum, set net_device->num_chn to the given
> value; else default to prior algorithm.
> 
> Always initialize struct device_info to 0, otherwise not all its fields
> are guaranteed to be 0, which is necessary when checking if num_chn has
> been purposefully set.
> 
> Signed-off-by: Andrew Schwartzmeyer <andschwa@microsoft.com>

Applied.
