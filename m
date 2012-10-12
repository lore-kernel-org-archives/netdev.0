From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: alignment faults in 3.6
Date: Fri, 12 Oct 2012 17:13:27 +0100
Message-ID: <1350058407.2819.15.camel@bwh-desktop.uk.solarflarecom.com>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com>
	 <yw1xtxu1nfsn.fsf@unicorn.mansr.com> <201210120811.43290.arnd@arndb.de>
	 <20121012090321.GA21164@n2100.arm.linux.org.uk>
	 <yw1xhaq0nefg.fsf@unicorn.mansr.com>
	 <20121012110750.GE21164@n2100.arm.linux.org.uk>
	 <yw1x8vbcndlb.fsf@unicorn.mansr.com>
	 <20121012114443.GG21164@n2100.arm.linux.org.uk>
	 <1350043692.21172.11815.camel@edumazet-glaptop>
	 <20121012142254.GG5453@kvack.org>
	 <1350053300.21172.12319.camel@edumazet-glaptop>
	 <1350054254.2819.3.camel@bwh-desktop.uk.solarflarecom.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7041@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@kvack.org>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	=?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Jon Masters <jonathan@jonmasters.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17307 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933105Ab2JLQNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 12:13:32 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7041@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-12 at 16:47 +0100, David Laight wrote:
> > AC was so useless that it has now been reallocated to use by SMAP
> > <https://lwn.net/Articles/517251/>.
> 
> That is a long time coming!
> Wonder when it will appear in any cpus.
> 
> How am I going to get root access when I can't get the kernel
> to execute code at address 0 any more :-)

Moving further off the topic: that is supposed to be prevented by a
separate feature, SMEP, which I think is available in current Intel CPUs
(Ivy Bridge).  Also, unprivileged users are generally not permitted to
mmap() at address 0.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
