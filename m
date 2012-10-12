From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: alignment faults in 3.6
Date: Fri, 12 Oct 2012 15:36:13 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B703F@saturn3.aculab.com>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk> <AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com> <yw1xtxu1nfsn.fsf@unicorn.mansr.com> <201210120811.43290.arnd@arndb.de> <20121012090321.GA21164@n2100.arm.linux.org.uk> <yw1xhaq0nefg.fsf@unicorn.mansr.com> <20121012110750.GE21164@n2100.arm.linux.org.uk> <yw1x8vbcndlb.fsf@unicorn.mansr.com> <20121012114443.GG21164@n2100.arm.linux.org.uk> <1350043692.21172.11815.camel@edumazet-glaptop> <20121012142254.GG5453@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Russell King - ARM Linux" <linux@arm.linux.org.uk>,
	=?Windows-1252?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>,
	"Arnd Bergmann" <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	"Jon Masters" <jonathan@jonmasters.org>
To: "Benjamin LaHaise" <bcrl@kvack.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59615 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751516Ab2JLOmD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 10:42:03 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 16520-04 for <netdev@vger.kernel.org>;
 Fri, 12 Oct 2012 15:41:58 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20121012142254.GG5453@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> x86 does have an alignment check flag that can be set in the flags register.
> Somehow, I doubt anyone would be willing to walk through all the noise the
> faults would likely trigger.

Someone has tried to set that (in userspace) on NetBSD.
The fault reporting has been fixed, but really nothing
works since optimised parts of libc deliberately do
misaligned transfers.

	David
