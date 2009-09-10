From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Wed, 09 Sep 2009 17:16:55 -0700 (PDT)
Message-ID: <20090909.171655.53596703.davem@davemloft.net>
References: <4AA819D8.1020306@Sun.COM>
	<20090909143514.0bd1e7ba@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joyce.Yu@sun.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49327
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754598AbZIJAQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 20:16:38 -0400
In-Reply-To: <20090909143514.0bd1e7ba@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 9 Sep 2009 14:35:14 -0700

> Shouldn't the vlan driver being doing pskb_may_pull()
> or pskb_pull() instead?

I thought about it, and my answer is 'probably not'.

Just like for eth_type_trans(), it's pretty reasonable to
expect the link level header to be linearized already.
