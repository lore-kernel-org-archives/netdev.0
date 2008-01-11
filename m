From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN]: nested VLAN: fix lockdep's recursive locking warning
Date: Thu, 10 Jan 2008 22:38:47 -0800 (PST)
Message-ID: <20080110.223847.120475061.davem@davemloft.net>
References: <47863A93.5060000@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47987
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751727AbYAKGis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 01:38:48 -0500
In-Reply-To: <47863A93.5060000@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 10 Jan 2008 16:32:35 +0100

> [VLAN]: nested VLAN: fix lockdep's recursive locking warning
> 
> Allow vlans nesting other vlans without lockdep's warnings (max. 2 levels
> i.e. parent + child). Thanks to Patrick McHardy for pointing a bug in the
> first version of this patch.
> 
> Reported-by: Benny Amorsen
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.
