From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] net: fix checksum features handling in
 netif_skb_features()
Date: Mon, 25 Aug 2014 17:23:53 -0700 (PDT)
Message-ID: <20140825.172353.145857012627747535.davem@davemloft.net>
References: <20140821.163320.476216950054835385.davem@davemloft.net>
	<20140825131622.6233CA0BB0@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140825131622.6233CA0BB0@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Mon, 25 Aug 2014 15:16:22 +0200 (CEST)

> This is follow-up to
> 
>   da08143b8520 ("vlan: more careful checksum features handling")
> 
> which introduced more careful feature intersection in vlan code,
> taking into account that HW_CSUM should be considered superset
> of IP_CSUM/IPV6_CSUM. The same is needed in netif_skb_features()
> in order to avoid offloading mismatch warning when vlan is
> created on top of a bond consisting of slaves supporting IP/IPv6
> checksumming but not vlan Tx offloading.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied and queued up for -stable, thanks.
