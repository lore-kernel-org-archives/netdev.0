From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1 net-next] ipconfig: move ic_dev_xid under
 IPCONFIG_BOOTP
Date: Wed, 09 Jul 2014 14:33:12 -0700 (PDT)
Message-ID: <20140709.143312.1847154920217915711.davem@davemloft.net>
References: <1404930921-14879-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, fengguang.wu@intel.com,
	kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404930921-14879-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Wed,  9 Jul 2014 20:35:21 +0200

> ic_dev_xid is only used in __init ic_bootp_recv under IPCONFIG_BOOTP
> and __init ic_dynamic under IPCONFIG_DYNAMIC(which is itself defined
> with the same IPCONFIG_BOOTP)
> 
> This patch fixes the following warning when IPCONFIG_BOOTP is not set:
>>> net/ipv4/ipconfig.c:146:15: warning: 'ic_dev_xid' defined but not used [-Wunused-variable]
>     static __be32 ic_dev_xid;  /* Device under configuration */
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Cc: Fengguang Wu <fengguang.wu@intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied, thank you.
