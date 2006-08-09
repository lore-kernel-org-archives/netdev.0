From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take5 0/4] kevent: Generic event handling mechanism.
Date: Wed, 9 Aug 2006 10:49:23 +0400
Message-ID: <20060809064923.GB7154@2ka.mipt.ru>
References: <20060808.225230.104030885.davem@davemloft.net> <20060809061159.GA5979@2ka.mipt.ru> <20060809062515.GA23527@2ka.mipt.ru> <20060808.233156.74748104.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: zach.brown@oracle.com, drepper@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:45741 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S965081AbWHIGtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 02:49:53 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060808.233156.74748104.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 11:31:56PM -0700, David Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Wed, 9 Aug 2006 10:25:15 +0400
> 
> > Unfortunately it is impossible to use list_empty(), since due to RCU
> > issues kevent can not use list_del_init(), so list_empty() will
> > always show that list is not empty.
> 
> I see, just use the LIST_POISON* scheme for now, it's something
> we can refine later.

I've fixed timout issue Zach pointed, and will reend kevent 'take6'
patchset without AIO stuff soon.
Question with kevents removal from syscall stays open until Ulrich
accepts or declines mapped buffer implementation.

-- 
	Evgeniy Polyakov
