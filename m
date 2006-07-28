From: Christophe Devriese <christophe.devriese@eth1.org>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Sat, 29 Jul 2006 00:15:29 +0200
Message-ID: <20060728221529.GB25610@walrus.eth1.org>
References: <20060728094421.GA14903@walrus.eth1.org> <44CA34D0.1070507@candelatech.com> <20060728215032.GA17930@walrus.eth1.org> <44CA87C5.1060905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth1.org ([85.158.215.1]:46520 "EHLO walrus.kotnet.org")
	by vger.kernel.org with ESMTP id S1161331AbWG1WHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2006 18:07:20 -0400
To: Linux netdev <netdev@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <44CA87C5.1060905@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 28, 2006 at 02:55:17PM -0700, Ben Greear wrote:
> Christophe Devriese wrote:
> >I basically move the skb_bond method into if_bonding.h, include that file
> >in if_vlan ( and call it from the vlan forwarding path, and the netif_rx
> >routine ). 
> >
> >Somehow this patch is very incomplete. Let me try again.
> 
> The patch looks sane this time.
> 
> The skb_bond method assigns skb->dev when it does the 'keep',
> but the VLAN code immediately over-writes the skb->dev when
> searching for the vlan device.
> 
> What is the purpose of assinging skb->dev to the master device?

I don't know. The method was only moved by this patch, not changed. The
contents of the method are exactly what they are in
linux-2.6.17.7/net/core/dev.c 

I assume it has something to do with the other bonding methods.

-- 
-----------------------------------------------------------------------
Christophe Devriese                                               EURiD
Network Adminstrator / Developer
christophe.devriese@eth1.org
---------------------------- http://www.eth1.org ----------------------
