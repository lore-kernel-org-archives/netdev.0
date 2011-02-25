From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Fri, 25 Feb 2011 17:58:32 -0500
Message-ID: <20110225225832.GD9763@canuck.infradead.org>
References: <AANLkTimDtaV=WhZUUEivg3_vEUeUk3_WQSs09h7USiUj@mail.gmail.com>
 <AANLkTi=j9VdTZjw4iTsczv2eHjTXo59-fNneBMo8rJyp@mail.gmail.com>
 <20110225125644.GA9763@canuck.infradead.org>
 <AANLkTinNost8Swh2fhQh8UXVdPTW_bToS7LXmyuwqNNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bill Sommerfeld <wsommerfeld@google.com>,
	Daniel Baluta <daniel.baluta@gmail.com>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:55737 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932539Ab1BYW6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 17:58:36 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTinNost8Swh2fhQh8UXVdPTW_bToS7LXmyuwqNNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 11:51:13AM -0800, Tom Herbert wrote:
> On the UDP side, I believe the patch is functional, but as Eric
> pointed out it probably could be further optimized.  I'll split out
> the UDP bits into a separate patch and post that...

Cool! I will be happy to assist in improving it further.

We already see 97-99% CPU utizliation spread evenly over all cores
(with about 20-30% spent in softirq) so at least it already scales
perfectly well.
