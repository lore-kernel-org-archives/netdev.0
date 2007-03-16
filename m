From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.21-rc3] IPV6: ipv6_fl_socklist is inadvertently
 shared.
Date: Fri, 16 Mar 2007 16:16:28 -0700 (PDT)
Message-ID: <20070316.161628.74748961.davem@davemloft.net>
References: <45FAD7C6.30305@ncos.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org, mhuth@mvista.com
To: nakagawa.msy@ncos.nec.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39071
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992450AbXCPXQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 19:16:29 -0400
In-Reply-To: <45FAD7C6.30305@ncos.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>
Date: Fri, 16 Mar 2007 10:45:42 -0700

> The ipv6_fl_socklist from listening socket is inadvertently shared
> with new socket created for connection.  This leads to a variety of
> interesting, but fatal, bugs. For example, removing one of the
> sockets may lead to the other socket's encountering a page fault
> when the now freed list is referenced.
> 
> The fix is to not share the flow label list with the new socket.
> 
> Signed-off-by: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>

Masayuki-san, thank you very much for this bug fix.

Patch applied.
