From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH -next] net namespace: build when SYSCTL=n
Date: Sat, 19 Jul 2008 03:33:51 +0100
Message-ID: <20080719023351.GT28946@ZenIV.linux.org.uk>
References: <20080718171812.8dfc9767.randy.dunlap@oracle.com> <20080718.180107.126477208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: randy.dunlap@oracle.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:38107 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbYGSCdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 22:33:54 -0400
Content-Disposition: inline
In-Reply-To: <20080718.180107.126477208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 18, 2008 at 06:01:07PM -0700, David Miller wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Fri, 18 Jul 2008 17:18:12 -0700
> 
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> > 
> > When CONFIG_SYSCTL=n, build fails with:
> > 
> > linux-next-20080718/include/net/net_namespace.h:40: error: field 'sysctls' has incomplete type
> > 
> > Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> 
> This 'sysctls' member isn't present in my networking tree, it must be
> coming from some other tree and thus the patch needs to be applied
> there.

Yup.  Applied.
