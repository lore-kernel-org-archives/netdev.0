From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: 3com: typhoon: fix typhoon_get_link_ksettings
Date: Wed, 09 Nov 2016 13:25:59 -0500 (EST)
Message-ID: <20161109.132559.2248490227331285339.davem@davemloft.net>
References: <1478440952-24973-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, sergei.shtylyov@cogentembedded.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478440952-24973-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sun,  6 Nov 2016 15:02:32 +0100

> When moving from typhoon_get_settings to typhoon_getlink_ksettings
> in the commit f7a5537cd2a5 ("net: 3com: typhoon: use new api
> ethtool_{get|set}_link_ksettings"), we use a local variable supported
> but we forgot to update the struct ethtool_link_ksettings with
> this value.
> 
> We also initialize advertising to zero, because otherwise it may
> be uninitialized if no case of the switch (tp->xcvr_select) is used.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
> Changelog:
> v2:
> - remove a duplicate "commit" in the commit log

Applied.
