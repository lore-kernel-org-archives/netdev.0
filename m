From: David Miller <davem@davemloft.net>
Subject: Re: [RFC RTNETLINK 03/09]: Split up rtnl_setlink
Date: Tue, 05 Jun 2007 12:41:07 -0700 (PDT)
Message-ID: <20070605.124107.122833220.davem@davemloft.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<20070605141255.15650.74711.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, ebiederm@xmission.com, tgraf@suug.ch
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54585
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763121AbXFETkw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 15:40:52 -0400
In-Reply-To: <20070605141255.15650.74711.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  5 Jun 2007 16:12:55 +0200 (MEST)

> [RTNETLINK]: Split up rtnl_setlink
> 
> Split up rtnl_setlink into a function performing validation and a function
> performing the actual changes. This allows to share the modifcation logic
> with rtnl_newlink, which is introduced by the next patch.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

This looks fine to me.
