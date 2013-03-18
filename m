From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Who/What is supposed to remove IPv6 address from interface when moving from one network to another ?
Date: Mon, 18 Mar 2013 19:34:07 +0100
Message-ID: <20130318183407.GA2740@order.stressinduktion.org>
References: <CAF6-1L4=xACZdqvJ6AZL4XkY17N0pC9PnPfNfK9Tk7QB47c1tw@mail.gmail.com> <CAF6-1L5cxguK8tHxjMACZJ8xNmAXLLXwP086eF4_SEctZdiZ3g@mail.gmail.com> <1363290495.1643.29.camel@dcbw.foobar.com> <CAKD1Yr1=1kfcSmRYgnrYQBhNPPc=nquB2c1jLbopbvqz848cxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Dan Williams <dcbw@redhat.com>,
	Sylvain Munaut <s.munaut@whatever-company.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42566 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752561Ab3CRSeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 14:34:09 -0400
Content-Disposition: inline
In-Reply-To: <CAKD1Yr1=1kfcSmRYgnrYQBhNPPc=nquB2c1jLbopbvqz848cxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 18, 2013 at 09:51:55AM -0700, Lorenzo Colitti wrote:
> On Thu, Mar 14, 2013 at 12:48 PM, Dan Williams <dcbw@redhat.com> wrote:
> > The kernel does not (and shouldn't) trigger anything on carrier change as that's a
> > site-specific/user-specific policy.
> 
> Actually, it *does* trigger events on carrier change: it creates the
> addresses when you connect. It just doesn't delete them when you
> disconnect. So you can get addresses without a userspace daemon, but
> you can never delete them without a userspace daemon.

Not directly related, but I wonder if we should treat the change of the
mac address as a carrier change in ipv6 to create a new ll address. I
did not find any satisfying answer yet.
