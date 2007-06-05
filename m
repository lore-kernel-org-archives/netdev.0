From: David Miller <davem@davemloft.net>
Subject: Re: [RFC RTNETLINK 02/09]: ifindex 0 does not exist
Date: Tue, 05 Jun 2007 12:40:42 -0700 (PDT)
Message-ID: <20070605.124042.68042112.davem@davemloft.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<20070605141253.15650.15698.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, ebiederm@xmission.com, tgraf@suug.ch
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54577
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762839AbXFETk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 15:40:27 -0400
In-Reply-To: <20070605141253.15650.15698.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  5 Jun 2007 16:12:54 +0200 (MEST)

> [RTNETLINK]: ifindex 0 does not exist
> 
> ifindex == 0 does not exist and implies we should do a lookup by name if
> one was given.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

This one is also more like a bug fix, thus applied.

I thought for a moment that perhaps we should signal an
error on ifindex==0 but I think this behavior you choose
makes more sense.
