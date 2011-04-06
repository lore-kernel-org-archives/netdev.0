From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen: drop anti-dependency on X86_VISWS
Date: Wed, 06 Apr 2011 14:45:15 -0700 (PDT)
Message-ID: <20110406.144515.235693855.davem@davemloft.net>
References: <1301828839.2837.143.camel@edumazet-laptop>
	<20110403.172407.91341067.davem@davemloft.net>
	<1301910955.23887.75.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org, Jeremy.Fitzhardinge@citrix.com,
	konrad.wilk@oracle.com, xen-devel@lists.xensource.com,
	virtualization@lists.linux-foundation.org, randy.dunlap@oracle.com,
	pazke@donpac.ru, linux-visws-devel@lists.sf.net,
	tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
To: Ian.Campbell@eu.citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54056
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932143Ab1DFVpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:45:52 -0400
In-Reply-To: <1301910955.23887.75.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Date: Mon, 4 Apr 2011 10:55:55 +0100

> You mean the "!X86_VISWS" I presume? It doesn't make sense to me either.

No, I think 32-bit x86 allmodconfig elides XEN because of it's X86_TSC dependency.

And, well, you could type "make allmodconfig" on your tree and see for
yourself instead of asking me :-)
