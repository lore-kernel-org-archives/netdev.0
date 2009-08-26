From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [net-next 6/10] bnx2x: Update vlan_features
Date: Wed, 26 Aug 2009 17:18:09 +0300
Message-ID: <4A954421.2010808@voltaire.com>
References: <1248191263.18195.49.camel@lb-tlvb-eilong> <4A683F83.1060701@trash.net> <4A68462C.1080709@Voltaire.com> <4A68479F.1000807@trash.net> <3426.1248464836@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:29094 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756678AbZHZOSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 10:18:25 -0400
In-Reply-To: <3426.1248464836@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> 	Patrick, can you clarify one bit about your above statment?  You
> say the bonding features should be an "intersection"; is that a strict
> intersection (i.e., slave1->vlan_features | slave2->vlan_features), or
> does the NETIF_F_ONE_FOR_ALL logic apply for vlan_features as it does
> for regular dev->features (using netdev_incrmenet_features() to combine
> the feature sets)?
>
> 	In other words, if a bond has two slaves, one with, e.g.,
> NETIF_F_SG in its vlan_features, and the other slave has 0 in
> vlan_features, should the bond's vlan_features be NETIF_F_SG, or 0?
>   
Hi Jay,

So we're @ rc7 again and the "bonding: propogate vlan_features to 
bonding master" patch isn't queued yet... can you look into that so we 
have this for 2.6.32?

thanks,

Or.

