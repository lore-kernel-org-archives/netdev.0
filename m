From: Glen Turner <gdt@gdt.id.au>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
	IRQF_SAMPLE_RANDOM
Date: Mon, 26 May 2008 00:32:02 +0930
Message-ID: <1211727722.5913.63.camel@andromache>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com>
	 <20080515142154.0595e475@core>
	 <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
	 <482C7B18.6060003@garzik.org> <482C7E53.3050300@hp.com>
	 <482C8184.2030906@garzik.org> <482C8550.5000909@intel.com>
	 <482C8D4D.3040702@garzik.org> <20080516132107.GA11304@csclub.uwaterloo.ca>
	 <20080516161029.44ded734@core> <20080516173610.GA27126@csclub.uwaterloo.ca>
	 <20080516191125.46f59ad6@core>   <m31w42gf97.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eth6445.sa.adsl.internode.on.net ([150.101.30.44]:35142 "EHLO
	aix.gdt.id.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753418AbYEYPCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2008 11:02:37 -0400
In-Reply-To: <m31w42gf97.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-05-16 at 22:34 +0200, Benny Amorsen wrote:

> Perhaps it would be possible to make most types of interrupts add
> entropy, but not credit any entropy?

You need to be certain that those sources are not able
to be influenced by a hostile party, otherwise the entropy
pool can be degraded to be less random over successive samples
than its entropy score suggests.  Interrupts do not meet that
test.

