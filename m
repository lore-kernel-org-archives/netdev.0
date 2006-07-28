From: Ben Greear <greearb@candelatech.com>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Fri, 28 Jul 2006 14:55:17 -0700
Message-ID: <44CA87C5.1060905@candelatech.com>
References: <20060728094421.GA14903@walrus.eth1.org> <44CA34D0.1070507@candelatech.com> <20060728215032.GA17930@walrus.eth1.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:34268 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1161323AbWG1VzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 17:55:19 -0400
To: Christophe Devriese <christophe.devriese@eth1.org>
In-Reply-To: <20060728215032.GA17930@walrus.eth1.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christophe Devriese wrote:
> I basically move the skb_bond method into if_bonding.h, include that file
> in if_vlan ( and call it from the vlan forwarding path, and the netif_rx
> routine ). 
> 
> Somehow this patch is very incomplete. Let me try again.

The patch looks sane this time.

The skb_bond method assigns skb->dev when it does the 'keep',
but the VLAN code immediately over-writes the skb->dev when
searching for the vlan device.

What is the purpose of assinging skb->dev to the master device?

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

