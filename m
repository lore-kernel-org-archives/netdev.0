From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: fix conflict between null_or_orig and
 null_or_bond
Date: Wed, 02 Jun 2010 03:35:54 -0700 (PDT)
Message-ID: <20100602.033554.67893995.davem@davemloft.net>
References: <20100513073106.3528.45412.stgit@jf-dev2-dcblab>
	<20100513073111.3528.19949.stgit@jf-dev2-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, fubar@us.ibm.com, nhorman@tuxdriver.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34576
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755222Ab0FBKfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 06:35:44 -0400
In-Reply-To: <20100513073111.3528.19949.stgit@jf-dev2-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Thu, 13 May 2010 00:31:11 -0700

> If a skb is received on an inactive bond that does not meet
> the special cases checked for by skb_bond_should_drop it should
> only be delivered to exact matches as the comment in
> netif_receive_skb() says.
> 
> However because null_or_bond could also be null this is not
> always true.  This patch renames null_or_bond to orig_or_bond
> and initializes it to orig_dev.  This keeps the intent of
> null_or_bond to pass frames received on VLAN interfaces stacked
> on bonding interfaces without invalidating the statement for
> null_or_orig.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Also applied.
