From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: alignment faults in 3.6
Date: Fri, 12 Oct 2012 10:22:54 -0400
Message-ID: <20121012142254.GG5453@kvack.org>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk> <AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com> <yw1xtxu1nfsn.fsf@unicorn.mansr.com> <201210120811.43290.arnd@arndb.de> <20121012090321.GA21164@n2100.arm.linux.org.uk> <yw1xhaq0nefg.fsf@unicorn.mansr.com> <20121012110750.GE21164@n2100.arm.linux.org.uk> <yw1x8vbcndlb.fsf@unicorn.mansr.com> <20121012114443.GG21164@n2100.arm.linux.org.uk> <1350043692.21172.11815.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	=?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	David Laight <David.Laight@aculab.com>, netdev@vger.kernel.org,
	Jon Masters <jonathan@jonmasters.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:53554 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932762Ab2JLOW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2012 10:22:56 -0400
Content-Disposition: inline
In-Reply-To: <1350043692.21172.11815.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 12, 2012 at 02:08:12PM +0200, Eric Dumazet wrote:
> So yes, we built network stack with the prereq that IP headers are
> aligned, but unfortunately many developers use x86 which doesnt care, so
> its possible some bugs are added.

x86 does have an alignment check flag that can be set in the flags register.  
Somehow, I doubt anyone would be willing to walk through all the noise the 
faults would likely trigger.

		-ben
-- 
"Thought is the essence of where you are now."
