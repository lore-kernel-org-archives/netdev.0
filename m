From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: cleanup the usage of vlan_dev_priv(dev)
Date: Sat, 03 Aug 2013 10:33:54 -0700 (PDT)
Message-ID: <20130803.103354.1511265539843796170.davem@davemloft.net>
References: <51FCC55A.808@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shhuiw@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51420 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752630Ab3HCRd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 13:33:57 -0400
In-Reply-To: <51FCC55A.808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Sheng-Hui <shhuiw@gmail.com>
Date: Sat, 03 Aug 2013 16:54:50 +0800

> 
> This patch cleanup 2 points for the usage of vlan_dev_priv(dev):
> * In vlan_dev.c/vlan_dev_hard_header, we should use the var *vlan directly
>   after grabing the pointer at the beginning with
>         *vlan = vlan_dev_priv(dev);
>   when we need to access the fields of *vlan.
> * In vlan.c/register_vlan_device, add the var *vlan pointer
>         struct vlan_dev_priv *vlan;
> to cleanup the code to access the fields of vlan_dev_priv(new_dev).
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>

Applied.
