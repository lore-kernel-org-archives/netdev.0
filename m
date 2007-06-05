From: David Miller <davem@davemloft.net>
Subject: Re: [RFC RTNETLINK 04/09]: Link creation API
Date: Tue, 05 Jun 2007 12:43:34 -0700 (PDT)
Message-ID: <20070605.124334.77407503.davem@davemloft.net>
References: <20070605141250.15650.47178.sendpatchset@localhost.localdomain>
	<20070605141256.15650.37514.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, hadi@cyberus.ca,
	xemul@sw.ru, ebiederm@xmission.com, tgraf@suug.ch
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54594
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1763282AbXFETnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 15:43:20 -0400
In-Reply-To: <20070605141256.15650.37514.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Tue,  5 Jun 2007 16:12:57 +0200 (MEST)

> [RTNETLINK]: Link creation API
> 
> Add rtnetlink API for creating, changing and deleting software devices.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Looks mostly fine, perhaps you can make even more use of 'const'
for instances of "struct rtnl_link_ops *" at least as function
arguments deeper in the implementation.
