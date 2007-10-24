From: David Miller <davem@davemloft.net>
Subject: Re: sch_prio.c vs CONFIG_NETDEVICES_MULTIQUEUE
Date: Tue, 23 Oct 2007 20:51:16 -0700 (PDT)
Message-ID: <20071023.205116.115906160.davem@davemloft.net>
References: <20071023121420.GB6267@localhost.sw.ru>
	<471DE660.4090004@trash.net>
	<471DF0A4.4080504@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, adobriyan@sw.ru, netdev@vger.kernel.org,
	peter.p.waskiewicz.jr@intel.com
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45168
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753584AbXJXDvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 23:51:31 -0400
In-Reply-To: <471DF0A4.4080504@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 23 Oct 2007 17:01:24 +0400

> Fix more users of netiff_subqueue_stopped. To check for the
> queue id one must use the __netiff_subqueue_stoped call.
> 
> These run out of my sight when I made the 
> 668f895a85b0c3a62a690425145f13dabebebd7a commit :(
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks Pavel.
