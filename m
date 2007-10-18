From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix again the fl6_sock_lookup() fixed locking
Date: Thu, 18 Oct 2007 05:38:59 -0700 (PDT)
Message-ID: <20071018.053859.27928990.davem@davemloft.net>
References: <4717536A.2080400@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org, yoshfuji@linux-ipv6.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56511
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757237AbXJRMip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 08:38:45 -0400
In-Reply-To: <4717536A.2080400@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Thu, 18 Oct 2007 16:36:58 +0400

> YOSHIFUJI fairly pointed out, that the users increment should
> be done under the ip6_sk_fl_lock not to give IPV6_FL_A_PUT a
> chance to put this count to zero and release the flowlabel.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thank you very much Pavel.
