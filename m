From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IGMP]: Optimize kfree_skb in igmp_rcv.
Date: Sat, 09 Feb 2008 23:22:57 -0800 (PST)
Message-ID: <20080209.232257.190420523.davem@davemloft.net>
References: <1202480057-23367-1-git-send-email-den@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56385
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758699AbYBJHW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2008 02:22:26 -0500
In-Reply-To: <1202480057-23367-1-git-send-email-den@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri,  8 Feb 2008 17:14:17 +0300

> Merge error paths inside igmp_rcv.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, but this kind of cleanup is borderline during this
time period.  Please queue such things up for when I open up
net-2.6.26, thanks.

Find some bugs to fix instead :-)
