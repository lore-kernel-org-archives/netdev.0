From: Florian Westphal <fw@strlen.de>
Subject: Re: Bad checksum on bridge with IP options
Date: Mon, 12 May 2014 15:51:41 +0200
Message-ID: <20140512135141.GA13945@breakpoint.cc>
References: <536F8C0F.4090206@davidnewall.com>
 <5370CB47.4010400@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:55228 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750986AbaELNvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 09:51:45 -0400
Content-Disposition: inline
In-Reply-To: <5370CB47.4010400@davidnewall.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Newall <davidn@davidnewall.com> wrote:
> I've got a patch which fixes the faulty checksums, and now ping
> works with RR or TS set.  I'm not quite sure, though, that it fixes
> the right thing.  I wonder if the problem is less that the checksum
> becomes wrong, and more that the route and timestamps ought not to
> be changed by the bridge interface.

Agree, bridge should not alter ip options.
