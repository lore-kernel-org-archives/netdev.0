From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH RESEND] e100/e1000: fixes and pci error recovery
Date: Thu, 08 Jun 2006 09:32:04 -0700
Message-ID: <44885104.7020705@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linas Vepstas <linas@linas.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr18.intel.com ([134.134.136.17]:54964 "EHLO
	orsfmr003.jf.intel.com") by vger.kernel.org with ESMTP
	id S964871AbWFHQd2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 12:33:28 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jeff,

This is a resend of several earlier sent (and Acked) patches for e100 and 
e1000. They are available on our git server and contain:

in branch upstream-fixes:
[1] e1000: fix irq sharing when running ethtool test
[2] e1000: remove risky prefetch on next_skb->data

against netdev-2.6#upstream-fixes e82b0f2cc21be905e504573483fa9542b15df96f

[ please note that patch 2 will need manual merging into #upstream ]

in branch upstream:
[3] e100: add PCI Error Recovery
[4] e1000: add PCI Error Recovery

against netdev-2.6#upstream 983f27d37d4fc72c252835cb2ee3103b360735a6

Please pull:

into #upstream-fixes:
   git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-fixes
into #upstream:
   git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream

Cheers,

Auke

Refs

[1] http://marc.theaimsgroup.com/?l=linux-netdev&m=114928689932374&w=2
[2] http://marc.theaimsgroup.com/?l=linux-netdev&m=114954878609885&w=2
[3] http://marc.theaimsgroup.com/?l=linux-netdev&m=114436228823926&w=2
[4] http://marc.theaimsgroup.com/?l=linux-pci&m=114325705604534&w=2
