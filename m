From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPV6]: Ensure to truncate result and return full
 length for sticky options.
Date: Fri, 09 Mar 2007 16:17:59 -0800 (PST)
Message-ID: <20070309.161759.69218776.davem@davemloft.net>
References: <20070309.101328.78855655.yoshfuji@linux-ipv6.org>
	<20070308.204845.125566290.davem@davemloft.net>
	<20070309234435.GE7920@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: chrisw@sous-sol.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48428
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767674AbXCJAR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 19:17:59 -0500
In-Reply-To: <20070309234435.GE7920@sequoia.sous-sol.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ugh, Chris, why is this patch against a copy of ipv6_sockglue.c
that doesn't have the NULL pointer fix applied?

Nevermind, it's obvious, so I fixed it up by hand, but please
patch against current sources expecially when we're all aware
of other fixes that have been made to this exact function over
the past few days.  Otherwise it makes a lot more work for me.

Thanks.
