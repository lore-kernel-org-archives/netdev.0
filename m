From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take5 0/4] kevent: Generic event handling mechanism.
Date: Wed, 9 Aug 2006 10:11:59 +0400
Message-ID: <20060809061159.GA5979@2ka.mipt.ru>
References: <11550230861383@2ka.mipt.ru> <44D902EF.8070809@oracle.com> <20060809053113.GB17446@2ka.mipt.ru> <20060808.225230.104030885.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: zach.brown@oracle.com, drepper@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57794 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030509AbWHIGMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 02:12:17 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060808.225230.104030885.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 10:52:30PM -0700, David Miller (davem@davemloft.net) wrote:
> > Using LIST_POISON is a flag that kevent is in appropriate queue or not,
> > I can add some flag into the structure, but why, if it is clear just by
> > looking into list's pointers.
> 
> What is wrong with using list_empty() as this indicator?

RCU only replaces ->prev pointer, and list_empty(entry) checks for
entry->next == head, but actually I do not see how kevent entry can
point to itself, so I will try this.

-- 
	Evgeniy Polyakov
