From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Wed, 6 Feb 2008 00:52:17 +0300
Message-ID: <20080205215216.GB24275@2ka.mipt.ru>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com> <20080205200211.GA26150@one.firstfloor.org> <20080205203911.GA9891@2ka.mipt.ru> <20080205212017.5db50114@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Glenn Griffin <ggriffin.kernel@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:53804 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758176AbYBEVw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 16:52:57 -0500
Content-Disposition: inline
In-Reply-To: <20080205212017.5db50114@core>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alan.

On Tue, Feb 05, 2008 at 09:20:17PM +0000, Alan Cox (alan@lxorguk.ukuu.org.uk) wrote:
> > Most (if not all) distributions have them enabled and window growing
> > works just fine. Actually I do not see any reason why connection
> > establishment handshake should prevent any run-time operations at all,
> > even if it was setup during handshake.
> 
> Syncookies are only triggered if the system is under a load where it
> would begin to lose connections otherwise. So they merely turn a DoS into
> a working if slightly slower setup (and > 64K windows don't matter for
> most normal users, especially on mobile devices).

SACK is actually a good idea for mobile devices, so preventing
syncookies from not getting into account some options (btw, does it work
with timestamps and PAWS?) is not a solution.

-- 
	Evgeniy Polyakov
