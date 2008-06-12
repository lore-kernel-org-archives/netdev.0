From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Fix for recently introduced rawv6 bug.
Date: Thu, 12 Jun 2008 15:23:36 -0700 (PDT)
Message-ID: <20080612.152336.171805540.davem@davemloft.net>
References: <20080612.144933.184241072.davem@davemloft.net>
	<20080612220553.GJ28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46215
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751163AbYFLWXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2008 18:23:36 -0400
In-Reply-To: <20080612220553.GJ28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Thu, 12 Jun 2008 23:05:53 +0100

> Why does ->destroy() return int, BTW?  All in-tree instances return
> 0 and AFAICS there's nothing caller could possibly do in case of
> error anyway...

Yes it could be changed to return "void" and I'll try to do
that in the net-next-2.6 tree.
