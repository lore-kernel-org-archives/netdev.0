From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH,RFC] skb->network_header and __vlan_put_tag()
Date: Tue, 17 Jun 2008 12:10:53 +0200
Message-ID: <m3prqgpe1e.fsf@ursa.amorsen.dk>
References: <20080616221525.GG27971@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:34522 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752989AbYFQKLD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jun 2008 06:11:03 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1K8Y9V-0002Wx-Vf
	for netdev@vger.kernel.org; Tue, 17 Jun 2008 10:11:01 +0000
Received: from hd5b9080a.c45-01-12.sta.perspektivbredband.net ([213.185.8.10])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 10:11:01 +0000
Received: from benny+usenet by hd5b9080a.c45-01-12.sta.perspektivbredband.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 17 Jun 2008 10:11:01 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek <buytenh@wantstofly.org> writes:

> I'm adding VLAN support to mv643xx_eth (which does not support HW
> insertion of a VLAN tag, but it does support HW checksumming when
> a VLAN tag is present, you just have to tell the HW how many bytes
> there are between the start of the packet and the IP header), and
> I'm ending up with code like this:
>
> 	if (skb->protocol == htons(ETH_P_8021Q))
> 		ip_header = ip_hdr(skb) + 4;
> 	else
> 		ip_header = ip_hdr(skb);

How well does this work when doing QinQ or QinQinQ?


/Benny


