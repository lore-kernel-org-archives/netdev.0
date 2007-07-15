From: David Miller <davem@davemloft.net>
Subject: Re: [RFC NET_SCHED 00/05]: Kill NET_CLS_POLICE
Date: Sun, 15 Jul 2007 00:00:59 -0700 (PDT)
Message-ID: <20070715.000059.66060619.davem@davemloft.net>
References: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52601
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752105AbXGOHA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 03:00:57 -0400
In-Reply-To: <20070709204611.1461.16465.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon,  9 Jul 2007 22:46:12 +0200 (MEST)

> [This is a resend because of a typo in Jamal's address that I believe
>  made vger reject the mails. Appologies in case they arrive twice.]
> 
> 
> These patches update the NET_CLS_ACT code to fully replace NET_CLS_POLICE
> and remove the old code. There is one incompatibility, please look at
> patch 4/5 for details.

Considering the amount of code you are able to kill, I think
the slight incompatability is definitely worth it.

These patches have sat long enough for objections to come up,
so I'm going to put this into my tree now.

We'll have enough time to revert or sort out any issues before
2.6.23-final goes out the door.
