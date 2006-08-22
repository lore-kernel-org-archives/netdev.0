From: Davide Libenzi <davidel@xmailserver.org>
Subject: Re: [take9 2/2] kevent: poll/select() notifications. Timer notifications.
Date: Tue, 22 Aug 2006 07:35:53 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0608220730030.14814@alien.or.mcafeemobile.com>
References: <1155536496588@2ka.mipt.ru> <11555364962857@2ka.mipt.ru>
 <20060816133014.GB32499@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>, tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from x35.xmailserver.org ([69.30.125.51]:65237 "EHLO
	x35.xmailserver.org") by vger.kernel.org with ESMTP id S932269AbWHVOgM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 10:36:12 -0400
Received: from alien.or.mcafeemobile.com
	by x35.dev.mdolabs.com with [XMail 1.23 ESMTP Server]
	id <S1E545F> for <netdev@vger.kernel.org> from <davidel@xmailserver.org>;
	Tue, 22 Aug 2006 07:35:54 -0700
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060816133014.GB32499@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 16 Aug 2006, Christoph Hellwig wrote:

> On Mon, Aug 14, 2006 at 10:21:36AM +0400, Evgeniy Polyakov wrote:
>>
>> poll/select() notifications. Timer notifications.
>>
>> This patch includes generic poll/select and timer notifications.
>>
>> kevent_poll works simialr to epoll and has the same issues (callback
>> is invoked not from internal state machine of the caller, but through
>> process awake).
>
> I'm not a big fan of duplicating code over and over.  kevent is a candidate
> for a generic event devlivery mechanisms which is a _very_ good thing.  But
> starting that system by duplicating existing functionality is not very nice.
>
> What speaks against a patch the recplaces the epoll core by something that
> build on kevent while still supporting the epoll interface as a compatibility
> shim?

Sorry, I'm catching up with a huge post-vacation backlog, so I didn't have 
the time to look at the source code. But, if kevent performance is same or 
better, and the external epoll interface is fully supported, than I think 
the shim layer idea is a good one. Provided the shim being smaller than 
eventpoll.c :)



- Davide


