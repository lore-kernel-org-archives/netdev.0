From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] cxgb4 patches V2
Date: Tue, 23 Feb 2010 14:40:54 -0800 (PST)
Message-ID: <20100223.144054.261850790.davem@davemloft.net>
References: <1266528256-20873-1-git-send-email-dm@chelsio.com>
	<20100221.223049.183064491.davem@davemloft.net>
	<4B842771.9000506@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39900
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754089Ab0BWWkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 17:40:39 -0500
In-Reply-To: <4B842771.9000506@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Tue, 23 Feb 2010 11:07:29 -0800

> Can you please clarify what exactly you want me to change about the
> macros?  I looked at a few other drivers in the tree and I saw shift
> macros with _SHIFT or _SH suffixes, masks tend to have _MASK or _MSK
> suffixes, etc.  Are you asking me basically to change our S_, V_, etc
> prefixes to _SHIFT, etc suffixes or are we talking about some other
> kind of change?  Please bear with me, I am trying to understand what
> you're asking for exactly.

Yes.  Don't put things at the beginning, start with the register
name then add things at the end for shifts, masks, etc.
