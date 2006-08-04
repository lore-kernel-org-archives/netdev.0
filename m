From: Bodo Eggert <7eggert@elstempel.de>
Subject: Re: [RFC] irqbalance: Mark in-kernel irqbalance as obsolete, set  to N by default
Date: Fri, 04 Aug 2006 23:48:16 +0200
Message-ID: <E1G97X3-0000pH-IY@be1.lrz>
References: <6EJUl-4br-13@gated-at.bofh.it> <6FXVd-1Gl-11@gated-at.bofh.it> <6G9jL-1Yg-41@gated-at.bofh.it>
Reply-To: 7eggert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:53462 "EHLO
	moutng.kundenserver.de") by vger.kernel.org with ESMTP
	id S1161505AbWHDVv5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 17:51:57 -0400
To: Arjan van de Ven <arjan@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven <arjan@linux.intel.com> wrote:

> to some degree the in kernel balancer cannot really make the level of
> decisions that a userspace balancer can make, at least not without ma=
king all
> kernel developers vomit ;)

If you make the drivers set a flag if they know their interrupts should=
 remain
mostly on one CPU, you can avoid the bad cases, and the rest you could =
gain
from using more clever algorithms should be(*) usurally less than what =
parsing
/proc/interrupts costs.

*) as in: I guess
--=20
Ich danke GMX daf=FCr, die Verwendung meiner Adressen mittels per SPF
verbreiteten L=FCgen zu sabotieren.

http://david.woodhou.se/why-not-spf.html
