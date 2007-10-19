From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] [Bug 9187] ir-functions.c:(.text+0xbce18): undefined
 reference to `input_event'
Date: Thu, 18 Oct 2007 22:57:03 -0700
Message-ID: <20071018225703.0fd8e74a.randy.dunlap@oracle.com>
References: <20071019035702.B5C7E108010@picon.linux-foundation.org>
	<4718385E.7050105@oracle.com>
	<20071018.220222.35036834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:56921 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756235AbXJSF6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 01:58:47 -0400
In-Reply-To: <20071018.220222.35036834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Oct 2007 22:02:22 -0700 (PDT) David Miller wrote:

> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Thu, 18 Oct 2007 21:53:50 -0700
> 
> > [bugme-daemon@bugzilla.kernel.org wrote:]
> > 
> > 
> > 
> > From: Randy Dunlap <randy.dunlap@oracle.com>
> > 
> > Drivers that use lro functions should depend on INET, otherwise they
> > may not link correctly.  Let's not select INET.  Select should be used
> > only for library-like code, not to enable subsystems.
> > 
> > ERROR: "lro_flush_all" [drivers/net/myri10ge/myri10ge.ko] undefined!
> > ERROR: "lro_receive_frags" [drivers/net/myri10ge/myri10ge.ko] undefined!
> > 
> > Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Acked-by: David S. Miller <davem@davemloft.net>
> 
> Jeff, please pick this one up too, thanks!


This patch is for kernel bugzilla #9186, not #9187.
Clerical error, sorry about that.

---
~Randy
