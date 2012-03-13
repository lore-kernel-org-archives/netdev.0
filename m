From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net/hyperv: Add support for vlan trunking from
 guests
Date: Mon, 12 Mar 2012 17:06:58 -0700 (PDT)
Message-ID: <20120312.170658.1637379523228794072.davem@davemloft.net>
References: <1331583650-29686-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1331583650-29686-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Mon, 12 Mar 2012 13:20:48 -0700

> This patch series add vlan trunking feature from guests. With this feature,
> a Linux guest can now configure multiple vlans through a single synthetic
> NIC on Win8 Hyper-V host.
> 
> Note: Both patches should go to the 'net-next' tree. The patch [1/2] is
> required by the vlan trunking feature [2/2]. So they should go together.
> 
> The bug in rndis_filter_receive() does NOT happen until we start to use 
> 'per-packet-data' by the vlan trunking feature, so the bug fix [1/2] isn't
> urgent to be applied into 'net' tree.

Both applied, thanks.
