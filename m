From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 16/17] get rid of the size argument of sock_sendmsg()
Date: Wed, 15 Apr 2015 03:15:46 -0700
Message-ID: <1429092946.7346.74.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1428787108-13650-16-git-send-email-viro@ZenIV.linux.org.uk>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB1DDB2@AcuExch.aculab.com>
	 <20150414163534.GZ889@ZenIV.linux.org.uk>
	 <20150414.135535.190405308746783212.davem@davemloft.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CB1E7FD@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'David Miller' <davem@davemloft.net>,
	"viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:35835 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754609AbbDOKPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 06:15:48 -0400
Received: by oign205 with SMTP id n205so16105003oig.2
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 03:15:47 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB1E7FD@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-15 at 08:37 +0000, David Laight wrote:
> From: David Miller
> > Sent: 14 April 2015 18:56
> > > On Tue, Apr 14, 2015 at 04:25:24PM +0000, David Laight wrote:
> > >> From: Al Viro
> > >> > Sent: 11 April 2015 22:18
> > >> > it's equal to iov_iter_count(&msg->msg_iter) in all cases
> > >>
> > >> I don't know whether this is guaranteed for iov[] that come from
> > >> userspace.
> > >>
> > >> In any case iov_iter_count() is non-trivial and you don't
> > >> really want to call it when unnecessary.
> > >
> > > Really?
> > >
> > > static inline size_t iov_iter_count(struct iov_iter *i)
> > > {
> > >         return i->count;
> > > }
> > 
> > This just made my day.
> 
> I hate accessor functions

It is quite clear you do not really tweak linux code, do you ?

Typical linux developers love them when they want to add in accessor a
debugging facility or logic.
