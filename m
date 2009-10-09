From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless-2.6 2009-10-08
Date: Fri, 9 Oct 2009 09:23:17 -0400
Message-ID: <20091009132317.GA22719@tuxdriver.com>
References: <20091008223454.GB2798@tuxdriver.com> <200910090108.08838.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57511 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367AbZJINbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 09:31:43 -0400
Content-Disposition: inline
In-Reply-To: <200910090108.08838.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 09, 2009 at 01:08:06AM +0200, Michael Buesch wrote:
> On Friday 09 October 2009 00:34:54 John W. Linville wrote:
> > Albert Herranz (1):
> >       b43: do not stack-allocate pio rx/tx header and tail buffers
> 
> Come on, this is _not_ funny anymore. I did _not_ ack this patch, because I do _not_ like it.
> I was planning to do a better solution, but I didn't have the time, yet.
> Can you _please_ either:
> - Wait for my ack before you apply random b43 patches
> or
> - Remove me from MAINTAINERS

Michael,

After Albert posted his first version of the patch, you said:

"Just embed it into struct b43_wl (surround it by #ifdef CONFIG_B43_PIO). No need
to kzalloc then and it saves some memory.
You also need to alloc 4 bytes for the tail buffer (that currently is on the stack, too)."

AFAICT he complied with that request when he posted the second version.
Since the patch seemed fine otherwise, I applied it; and since it is
a fix I sent it on for 2.6.32.

As Dave suggested, there is plenty of time to fix it "properly"
for 2.6.33 and beyond.  I'm happy to accomodate you.

John

P.S.  Please understand that while some driver maintainers want to
ack every patch, others see that as a burden and get annoyed with me
if I don't apply reasonable patches without bothering them.  It can
be a bit difficult these things...
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
