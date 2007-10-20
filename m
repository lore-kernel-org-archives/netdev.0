From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [Bug 9187] ir-functions.c:(.text+0xbce18): undefined
 reference to `input_event'
Date: Fri, 19 Oct 2007 23:04:01 -0400
Message-ID: <47197021.3080601@garzik.org>
References: <20071019035702.B5C7E108010@picon.linux-foundation.org> <4718385E.7050105@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, NetDev <netdev@vger.kernel.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43449 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756995AbXJTDEF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 23:04:05 -0400
In-Reply-To: <4718385E.7050105@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote:
> [bugme-daemon@bugzilla.kernel.org wrote:]
> 
> 
> 
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Drivers that use lro functions should depend on INET, otherwise they
> may not link correctly.  Let's not select INET.  Select should be used
> only for library-like code, not to enable subsystems.
> 
> ERROR: "lro_flush_all" [drivers/net/myri10ge/myri10ge.ko] undefined!
> ERROR: "lro_receive_frags" [drivers/net/myri10ge/myri10ge.ko] undefined!
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

applied


