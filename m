From: David Miller <davem@davemloft.net>
Subject: Re: Fix for ipv6_setsockopt NULL dereference
Date: Fri, 09 Mar 2007 13:54:32 -0800 (PST)
Message-ID: <20070309.135432.129450538.davem@davemloft.net>
References: <200703091207.31877.olaf.kirch@oracle.com>
	<200703091515.55985.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: olaf.kirch@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38479
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752095AbXCIVyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 16:54:32 -0500
In-Reply-To: <200703091515.55985.olaf.kirch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Olaf Kirch <olaf.kirch@oracle.com>
Date: Fri, 9 Mar 2007 15:15:54 +0100

> I came across this bug in http://bugzilla.kernel.org/show_bug.cgi?id=8155
> 
> Here's a potential fix.
> 
> Olaf
> -- 
> Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
> okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
> --
> Fix NULL pointer derefence in ipv6_setsockopt, as described in bug #8155.
> 
> Signed-off-by: olaf.kirch@oracle.com

Applied, thanks a lot Olaf.

I'll push this to -stable too.
