From: David Miller <davem@davemloft.net>
Subject: Re: [take5 0/4] kevent: Generic event handling mechanism.
Date: Tue, 08 Aug 2006 22:52:30 -0700 (PDT)
Message-ID: <20060808.225230.104030885.davem@davemloft.net>
References: <11550230861383@2ka.mipt.ru>
	<44D902EF.8070809@oracle.com>
	<20060809053113.GB17446@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zach.brown@oracle.com, drepper@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:60550
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030489AbWHIFw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 01:52:29 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060809053113.GB17446@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Wed, 9 Aug 2006 09:31:14 +0400

I am burnt out on reviewing this endless kevent patch resubmissions,
so I will only comment briefly.

> That's why I'm asking for what exactly should be moved into the
> patchset. I.e. do we need poll/select (it is the same as what epoll
> does), timer, network AIO? How they should be splitted?

I would suggest removing all of the file I/O and network AIO since
they are logically seperate from kevent.

> Using LIST_POISON is a flag that kevent is in appropriate queue or not,
> I can add some flag into the structure, but why, if it is clear just by
> looking into list's pointers.

What is wrong with using list_empty() as this indicator?
