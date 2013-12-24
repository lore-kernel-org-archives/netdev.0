From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv4 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Tue, 24 Dec 2013 11:35:21 +0100
Message-ID: <20131224103521.GB29716@secunet.com>
References: <1387337658-28951-1-git-send-email-fan.du@windriver.com>
 <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>
 <52B24D7D.6060902@windriver.com>
 <1387419308.19078.343.camel@edumazet-glaptop2.roam.corp.google.com>
 <52B26553.9070103@windriver.com>
 <1387424650.19078.355.camel@edumazet-glaptop2.roam.corp.google.com>
 <52B3BAD1.30205@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	=?utf-8?B?546L6IGq?= <xiyou.wangcong@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52151 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751486Ab3LXKf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Dec 2013 05:35:27 -0500
Content-Disposition: inline
In-Reply-To: <52B3BAD1.30205@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 20, 2013 at 11:34:41AM +0800, Fan Du wrote:
> 
> Subject: [PATCHv4 net-next] xfrm: Namespacify xfrm_policy_sk_bundles
> 
> xfrm_policy_sk_bundles, protected by net->xfrm.xfrm_policy_sk_bundle_lock
> should be put into netns xfrm structure, otherwise xfrm_policy_sk_bundles
> can be corrupted from different net namespace.

I'm ok with this patch, but I wonder where we use these cached socket
bundles. After a quick look I see where we add and where we delete
them, but I can't see how we use these cached bundles. 
