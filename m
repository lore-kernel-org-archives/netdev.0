From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Sun, 16 Jul 2006 19:02:48 -0700 (PDT)
Message-ID: <20060716.190248.08325486.davem@davemloft.net>
References: <20060715.181222.74751444.davem@davemloft.net>
	<200607161120.k6GBKZEG009486@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, shemminger@osdl.org, guichaz@yahoo.fr,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63699
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932204AbWGQCCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 22:02:33 -0400
To: chas3@users.sourceforge.net, chas@cmf.nrl.navy.mil
In-Reply-To: <200607161120.k6GBKZEG009486@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Date: Sun, 16 Jul 2006 07:20:35 -0400

> why does the input side of the ip layer believe the cb contains valid
> data?  it should zero the contents of the cb, or just fill in the cb
> correctly when the packet arrives at its doorstop.

Yes, that's right, after hearing your and Herbert's comments,
this point of view is clearly right :)
