From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Wed, 6 Feb 2008 09:53:57 +0100
Message-ID: <20080206085357.GA1402@one.firstfloor.org>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com> <20080205155558.GA23145@one.firstfloor.org> <c9e534200802051029u5d08cf6dm54866f769e362262@mail.gmail.com> <20080205192559.GA10573@kallisti.us> <20080205201106.GB26150@one.firstfloor.org> <20080205212335.GA11287@kallisti.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Glenn Griffin <ggriffin.kernel@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ross Vandegrift <ross@kallisti.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:43314 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbYBFITD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 03:19:03 -0500
Content-Disposition: inline
In-Reply-To: <20080205212335.GA11287@kallisti.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I work at a hosting company and we see these kinds of issues in the
> real world fairly frequently.  I would guess maybe a monthly basis.
> The servers where we have seen this are typically running RHEL 4 or 5
> kernels, so I can't really speak to how recent the kernel is in this
> specific term.

RHEL5 should be recent enough.

> 
> If I can find a box that we could temporary get a kernel.org kernel
> on, I'll see if I can get a real comparison together.  We have
> collected a few of the more effective attack tools that have been left
> on compromised systems, so it wouldn't be too difficult to get some
> numbers.

That would be useful yes -- for different bandwidths.

If the young/old heuristics do not work well enough anymore most likely we should
try readding RED to the syn queue again. That used to be pretty effective
in the early days. I don't quite remember why Linux didn't end up using it
in fact.

-Andi

