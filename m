From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: cleanup the usage of vlan_dev_priv(dev)
Date: Fri, 02 Aug 2013 17:33:11 -0700 (PDT)
Message-ID: <20130802.173311.1369362183750230796.davem@davemloft.net>
References: <51FC4D52.7070607@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shhuiw@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162Ab3HCAdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 20:33:12 -0400
In-Reply-To: <51FC4D52.7070607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Sheng-Hui <shhuiw@gmail.com>
Date: Sat, 03 Aug 2013 08:22:42 +0800

> This patch cleanup 2 points for the usage of vlan_dev_priv(dev):
> 	* In vlan_dev.c/vlan_dev_hard_header, we should use the var *vlan
> 	* directly
> 	  after grabing the pointer at the beginning with
> 	      *vlan = vlan_dev_priv(dev);
>       when we need to access the fields of *vlan.
> 	* In vlan.c/register_vlan_device, add the var *vlan pointer
> 	      struct vlan_dev_priv *vlan;
> 	  to cleanup the code to access the fields of vlan_dev_priv(new_dev).
> 
> Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>

This patch doesn't even come close to applying to the net-next tree:

patching file net/8021q/vlan.c
Hunk #1 FAILED at 210.
Hunk #2 succeeded at 260 with fuzz 2.
1 out of 2 hunks FAILED -- saving rejects to file net/8021q/vlan.c.rej
patching file net/8021q/vlan_dev.c
Hunk #1 FAILED at 107.
Hunk #2 FAILED at 133.
2 out of 2 hunks FAILED -- saving rejects to file net/8021q/vlan_dev.c.rej

Please respin your changes and resubmit, thanks.
