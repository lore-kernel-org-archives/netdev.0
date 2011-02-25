From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Fri, 25 Feb 2011 07:56:44 -0500
Message-ID: <20110225125644.GA9763@canuck.infradead.org>
References: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
 <AANLkTi=j9VdTZjw4iTsczv2eHjTXo59-fNneBMo8rJyp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Baluta <daniel.baluta@gmail.com>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>,
	Bill Sommerfeld <wsommerfeld@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:46944 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056Ab1BYM4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 07:56:47 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTi=j9VdTZjw4iTsczv2eHjTXo59-fNneBMo8rJyp@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 27, 2011 at 01:32:25PM -0800, Tom Herbert wrote:
> Yes, we are still planning this.  The UDP implementation for my
> earlier patch should be usable to try for DNS/UDP-- this is in fact
> where we saw a major performance gain.  Eric Dumazet had some nice
> improvements that should probably be looked at also.

I can confirm this.

Serious scalability issues have been reported on a 12 core system
running bind 9.7-2. The system was only able to deliver ~110K queries
per second.

Using your SO_REUSEPORT patch and a modified bind using it. The same
system is able to deliver ~650K queries per seconds while maxing out
all cores completely.

Tom, Bill: do you have a timeline for merging this? Especially the
UDP bits?

-Thomas
