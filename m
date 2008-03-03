From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 net-2.6.26] [IPV4]: skb->dst can't be NULL in
 ip_options_echo.
Date: Mon, 03 Mar 2008 11:50:19 -0800 (PST)
Message-ID: <20080303.115019.79605096.davem@davemloft.net>
References: <1204559323-19953-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57728
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750991AbYCCTuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 14:50:35 -0500
In-Reply-To: <1204559323-19953-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Mon,  3 Mar 2008 18:48:40 +0300

> ip_options_echo is called on the packet input path after the initial
> routing. The dst entry on the packet is cleared only in the several
> very specific places and immidiately assigned back (may be new).
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks.
