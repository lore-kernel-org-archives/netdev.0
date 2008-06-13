From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net: reorder udp_iter_state to remove padding on 64bit
 builds
Date: Fri, 13 Jun 2008 03:03:26 -0700 (PDT)
Message-ID: <20080613.030326.60083578.davem@davemloft.net>
References: <1212662019.3039.14.camel@castor.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: richard@rsk.demon.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41680
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755876AbYFMKD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jun 2008 06:03:26 -0400
In-Reply-To: <1212662019.3039.14.camel@castor.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Kennedy <richard@rsk.demon.co.uk>
Date: Thu, 05 Jun 2008 11:33:39 +0100

> reorder udp_iter_state to remove padding on 64bit builds
> 
> shrinks from 24 to 16 bytes, moving to a smaller slab when CONFIG_NET_NS
> is undefined & seq_net_private = {}
> 
> Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>

Applied, th anks Richard.
