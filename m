From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp_probe: __attribute__ string location
Date: Tue, 05 Jun 2007 19:05:18 -0700 (PDT)
Message-ID: <20070605.190518.75190350.davem@davemloft.net>
References: <20070605180141.e4692374.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51760
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763431AbXFFCFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 22:05:08 -0400
In-Reply-To: <20070605180141.e4692374.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 5 Jun 2007 18:01:41 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> gcc doesn't like the location of the __attribute__ string here:
> net/ipv4/tcp_probe.c:83: warning: empty declaration
> 
> so move it to before the function and all is well.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Yeah I noticed this one too and a similar fix is in
my net-2.6 GIT tree, but thanks anyways Randy.
