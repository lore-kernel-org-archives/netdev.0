From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Sat, 17 Nov 2007 16:04:49 +0100
Message-ID: <473F0311.6060200@o2.pl>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>	 <20071115082600.GA2366@ff.dom.local>	 <20071115102005.0cf46f9a@freepuppy.rosehill> <473CD1F6.9030709@o2.pl>	 <cccedfc60711151842l4aafe0ffo220e84a5e37b6a82@mail.gmail.com>	 <20071115203508.4ad025f2@freepuppy.rosehill>	 <cccedfc60711160821p5f1790eaq8d385e71726cd5a0@mail.gmail.com>	 <20071116084706.467aa834@freepuppy.rosehill> <cccedfc60711161659s73477594lb0ff57b9bcbd7f24@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: Jon Nelson <jnelson@jamponi.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:43251 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753938AbXKQPDG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Nov 2007 10:03:06 -0500
In-Reply-To: <cccedfc60711161659s73477594lb0ff57b9bcbd7f24@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Nelson wrote, On 11/17/2007 01:59 AM:
...

> OK. This is what I did.
> Using git I grabbed a copy of Linus' tree and using the latest files
> for via-velocity.[c,h], commit
> 99fee6d7e5748d96884667a4628118f7fc130ea0, I determined that if I
> backed out change 44c10138fd4bbc4b6d6bff0873c24902f2a9da65 (PCI:
> Change all drivers to use pci_device->revision) I could get it to
> compile. This gets me a more recent driver.
> 
> Then I applied both of the patches you have provided me, and built and
> tried that.
> No sigseg, no oops on initial MTU, no sigseg or oops on subsequent MTU changes.


Good news! But, if I got it right your method could be tricky. These
current via-velocity files could depend on other files being current
as well. So, it's safer to use the whole new kernel (eg. 2.6.24-rc3)
or to stay with your older one. But, if you want to check the effect
of these new two patches only without any additional 'features', your
older kernel should be a better choice.

Regards,
Jarek P.
