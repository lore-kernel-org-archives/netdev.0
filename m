From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: vlan, qlcnic: make vlan_find_dev private
Date: Sun, 17 Jul 2011 12:33:58 -0700 (PDT)
Message-ID: <20110717.123358.556106070658579125.davem@davemloft.net>
References: <1310928792-3436326-1-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, amit.salecha@qlogic.com,
	anirban.chakraborty@qlogic.com, linux-driver@qlogic.com
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756242Ab1GQTgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jul 2011 15:36:43 -0400
In-Reply-To: <1310928792-3436326-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Sun, 17 Jul 2011 20:53:12 +0200

> there is only one user of vlan_find_dev outside of the actual vlan code:
> qlcnic uses it to iterate over some VLANs it knows.
> 
> let's just make vlan_find_dev private to the VLAN code and have the
> iteration in qlcnic be a bit more direct. (a few rcu dereferences less
> too)
> 
> Signed-off-by: David Lamparter <equinox@diac24.net>

Applied.
