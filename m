From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/2] [IPV6]: Ensure to truncate result and return full
 length for sticky options.
Date: Sat, 10 Mar 2007 10:13:28 +0900 (JST)
Message-ID: <20070310.101328.32265651.yoshfuji@linux-ipv6.org>
References: <20070308.204845.125566290.davem@davemloft.net>
	<20070309234435.GE7920@sequoia.sous-sol.org>
	<20070309.161506.70220159.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chrisw@sous-sol.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34555 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767709AbXCJBNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 20:13:04 -0500
In-Reply-To: <20070309.161506.70220159.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070309.161506.70220159.davem@davemloft.net> (at Fri, 09 Mar 2007 16:15:06 -0800 (PST)), David Miller <davem@davemloft.net> says:

> > on arch's that don't protect < 0 copy_to_user like i386 does).  Here's
> > a simple fix ontop of yoshifuji's two changes.  Hope that's it ;-)
> 
> copy_to_user() will check it, actually, it will make sure that
> optval + len doesn't wrap or overlap into kernel space.
> 
> Actually, like sparc64 it BUG's on negative length so we have
> to fix this :-)

Oh I did not know this BUG.
Anyway, thanks for taking care of this.

--yoshfuji
