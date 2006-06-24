From: "Steve Wise" <swise@opengridcomputing.com>
Subject: Re: [PATCH REPOST 1/2] Network Event Notifier Mechanism.
Date: Fri, 23 Jun 2006 21:27:19 -0500
Message-ID: <001001c69735$b808e790$020010ac@haggard>
References: <20060623201928.32482.69191.stgit@stevo-desktop><20060623.132647.39159829.davem@davemloft.net><1151094895.7808.87.camel@stevo-desktop> <20060623.135642.48528981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aoot.com ([67.65.16.241]:31507 "EHLO aoot.com")
	by vger.kernel.org with ESMTP id S933187AbWFXC1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 22:27:25 -0400
To: "David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


----- Original Message ----- 
From: "David Miller" <davem@davemloft.net>
To: <swise@opengridcomputing.com>
Cc: <netdev@vger.kernel.org>
Sent: Friday, June 23, 2006 3:56 PM
Subject: Re: [PATCH REPOST 1/2] Network Event Notifier Mechanism.


| From: Steve Wise <swise@opengridcomputing.com>
| Date: Fri, 23 Jun 2006 15:34:55 -0500
|
| > But what about the redirect event?  It really needs to pass two bits 
of
| > info:  The old dst_entry ptr and the new dst_entry ptr.  This is 
needed
| > so the rdma driver can figure out which connections now need to use 
the
| > new dst_entry...
|
| struct foo_event_data {
| struct whatever a;
| struct thistoo b;
| };
|
| struct foo_event_data x;
|
| x->a = xxx;
| x->b = yyy;
|
| event->data = (void *) &x;
| send_event(&event);
|
| Why do you need typed data to do this?
|

You don't.  This is fine with me...



