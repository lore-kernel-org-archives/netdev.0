From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: alignment faults in 3.6
Date: Fri, 12 Oct 2012 16:48:20 +0200
Message-ID: <1350053300.21172.12319.camel@edumazet-glaptop>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	=?ISO-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	Arnd Bergmann <arnd@arndb.de>,
	linux-arm-kernel@lists.infradead.org,
	David Laight <David.Laight@aculab.com>, netdev@vger.kernel.org,
	Jon Masters <jonathan@jonmasters.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:65298 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab2JLOsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 10:48:24 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1606778bkc.19
        for <netdev@vger.kernel.org>; Fri, 12 Oct 2012 07:48:23 -0700 (PDT)
In-Reply-To: <20121012142254.GG5453@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-10-12 at 10:22 -0400, Benjamin LaHaise wrote:
> On Fri, Oct 12, 2012 at 02:08:12PM +0200, Eric Dumazet wrote:
> > So yes, we built network stack with the prereq that IP headers are
> > aligned, but unfortunately many developers use x86 which doesnt care, so
> > its possible some bugs are added.
> 
> x86 does have an alignment check flag that can be set in the flags register.  
> Somehow, I doubt anyone would be willing to walk through all the noise the 
> faults would likely trigger.

If this can be mapped to an event that can be used by perf tool, that
might be useful ?
