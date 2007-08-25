From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [RFC] E1000: Fix hang in netdev_wait_allrefs()
Date: Fri, 24 Aug 2007 23:08:37 -0700 (PDT)
Message-ID: <20070824.230837.54195644.davem@davemloft.net>
References: <20070823090418.13099.89298.sendpatchset@localhost.localdomain>
	<20070823090431.13099.2597.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40412
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751200AbXHYGIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 02:08:38 -0400
In-Reply-To: <20070823090431.13099.2597.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Krishna Kumar <krkumar2@in.ibm.com>
Date: Thu, 23 Aug 2007 14:34:31 +0530

> After applying patch1, I started getting "waiting for count" messages when
> doing ifdown. Not sure if this is the right fix since the count was already
> showing as -1 in that message, but this patch fixes the problem.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>

I've applied this because is fixes the problem and there have
be no objections coming along with better fixes :)

If this is bogus we can rever it and put in a more proper fix.
