From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [git patches] net driver fixes
Date: Fri, 14 Sep 2007 13:39:44 -0700
Message-ID: <31488.1189802384@death>
References: <20070913053022.GA16891@havoc.gtf.org> <1189793598.2508.4.camel@xo-3E-67-34.localdomain> <46EAD049.4020107@garzik.org> <1189794677.2508.19.camel@xo-3E-67-34.localdomain> <32620.1189797572@death> <1189800717.20386.13.camel@xo-3E-67-34.localdomain>
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:53713 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752717AbXINUjr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Sep 2007 16:39:47 -0400
In-reply-to: <1189800717.20386.13.camel@xo-3E-67-34.localdomain> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams <dcbw@redhat.com> wrote:
[...]
>So essentially the ehea device has a 1(+) external ports that may/may
>not be connected, but all lpars share the physical hardware itself,
>which is quite happy to let all the lpars talk to each other essentially
>via loopback even if there is no actual carrier detected on the external
>port(s)? [...]

	Yes.

>[...]  How does addressing work here, is it just L2 addresses?  

	Yes.  The logical ports all have unique MAC addresses.

> [...] Feel
>free to point me to some docs and tell me to shut up :)

http://www.redbooks.ibm.com/redpieces/abstracts/redp4340.html

	I found this via google; I haven't read it in detail, but it
seems to cover the HEA architecture at a high level.  It talks about the
whole "IVE" (integrated virtual ethernet: the adapter, hypervisor, etc)
system, but HEA is part of that, so it's probably got the answers you're
looking for.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
