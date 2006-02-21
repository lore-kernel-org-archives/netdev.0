From: "David S. Miller" <davem@davemloft.net>
Subject: Re: 2.6.16-rc4 bridge/iptables Oops
Date: Mon, 20 Feb 2006 20:07:03 -0800 (PST)
Message-ID: <20060220.200703.132025777.davem@davemloft.net>
References: <43FA0C02.8000909@trash.net>
	<200602210211.22364.earny@net4u.de>
	<43FA8439.6080009@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: earny@net4u.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161310AbWBUEGy@vger.kernel.org>
To: kaber@trash.net
In-Reply-To: <43FA8439.6080009@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 21 Feb 2006 04:08:41 +0100

> Thanks for testing. Dave, please take this patch instead, it avoids
> having to guess whether a packet originates from bridging in IP
> netfilter by using DST_NOXFRM for bridge-netfilter's fake dst_entry.

Applied, thanks Patrick.
