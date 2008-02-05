From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 23:39:11 +0300
Message-ID: <20080205203911.GA9891@2ka.mipt.ru>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com> <20080205200211.GA26150@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Glenn Griffin <ggriffin.kernel@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:55758 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758234AbYBEUkA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 15:40:00 -0500
Content-Disposition: inline
In-Reply-To: <20080205200211.GA26150@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 05, 2008 at 09:02:11PM +0100, Andi Kleen (andi@firstfloor.org) wrote:
> On Tue, Feb 05, 2008 at 10:29:28AM -0800, Glenn Griffin wrote:
> > > Syncookies are discouraged these days. They disable too many
> > > valuable TCP features (window scaling, SACK) and even without them
> > > the kernel is usually strong enough to defend against syn floods
> > > and systems have much more memory than they used to be.
> > >
> > > So I don't think it makes much sense to add more code to it, sorry.

How does syncookies prevent windows from growing?
Most (if not all) distributions have them enabled and window growing
works just fine. Actually I do not see any reason why connection
establishment handshake should prevent any run-time operations at all,
even if it was setup during handshake.

-- 
	Evgeniy Polyakov
