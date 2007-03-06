From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] div64_64 support
Date: Tue, 6 Mar 2007 14:36:08 +0100
Message-ID: <20070306133608.GB864@one.firstfloor.org>
References: <20070226143127.5c74bec9@freekitty> <p73slcnawh3.fsf@bingen.suse.de> <20070305155714.3abe1b5e@freekitty> <20070305.162551.41660347.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, andi@firstfloor.org,
	jengelh@linux01.gwdg.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:44890 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933280AbXCFNgK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 08:36:10 -0500
Content-Disposition: inline
In-Reply-To: <20070305.162551.41660347.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 04:25:51PM -0800, David Miller wrote:
> Another thing is that the non-Hacker's Delight version iterates
> differently for different input values, so the input value space is
> very important to consider when comparing these two pieces of code.

I did some stochastic testing on my version. It gave 1 off for < 1% of
the arguments.  Probably not an issue.

Besides it actually works for >2^43 @)

-Andi
