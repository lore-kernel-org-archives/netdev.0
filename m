From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 16/17] get rid of the size argument of sock_sendmsg()
Date: Wed, 15 Apr 2015 08:37:01 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB1E7FD@AcuExch.aculab.com>
References: <1428787108-13650-16-git-send-email-viro@ZenIV.linux.org.uk>
	<063D6719AE5E284EB5DD2968C1650D6D1CB1DDB2@AcuExch.aculab.com>
	<20150414163534.GZ889@ZenIV.linux.org.uk>
 <20150414.135535.190405308746783212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'David Miller' <davem@davemloft.net>,
	"viro@ZenIV.linux.org.uk" <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:55849 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751909AbbDOIi7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 04:38:59 -0400
In-Reply-To: <20150414.135535.190405308746783212.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> Sent: 14 April 2015 18:56
> > On Tue, Apr 14, 2015 at 04:25:24PM +0000, David Laight wrote:
> >> From: Al Viro
> >> > Sent: 11 April 2015 22:18
> >> > it's equal to iov_iter_count(&msg->msg_iter) in all cases
> >>
> >> I don't know whether this is guaranteed for iov[] that come from
> >> userspace.
> >>
> >> In any case iov_iter_count() is non-trivial and you don't
> >> really want to call it when unnecessary.
> >
> > Really?
> >
> > static inline size_t iov_iter_count(struct iov_iter *i)
> > {
> >         return i->count;
> > }
> 
> This just made my day.

I hate accessor functions

	David
