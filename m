From: David Miller <davem@davemloft.net>
Subject: Re: [take5 0/4] kevent: Generic event handling mechanism.
Date: Tue, 08 Aug 2006 23:31:56 -0700 (PDT)
Message-ID: <20060808.233156.74748104.davem@davemloft.net>
References: <20060808.225230.104030885.davem@davemloft.net>
	<20060809061159.GA5979@2ka.mipt.ru>
	<20060809062515.GA23527@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zach.brown@oracle.com, drepper@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26810
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030542AbWHIGbz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 02:31:55 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060809062515.GA23527@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 9 Aug 2006 10:25:15 +0400

> Unfortunately it is impossible to use list_empty(), since due to RCU
> issues kevent can not use list_del_init(), so list_empty() will
> always show that list is not empty.

I see, just use the LIST_POISON* scheme for now, it's something
we can refine later.
