From: Andi Kleen <andi@firstfloor.org>
Subject: Re: 3.5.1 fib_rules_lookup oops
Date: Mon, 20 Aug 2012 13:35:34 -0700
Message-ID: <m2zk5p7149.fsf@firstfloor.org>
References: <20120820164428.GA27910@redhat.com>
	<1345481979.5158.333.camel@edumazet-glaptop>
	<20120820172240.GA378@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44991 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751920Ab2HTUfg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 16:35:36 -0400
In-Reply-To: <20120820172240.GA378@redhat.com> (Dave Jones's message of "Mon,
	20 Aug 2012 13:22:40 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave Jones <davej@redhat.com> writes:
>
> Same user reported a slew of other problems, so he may have bad hardware.
> I've asked him to run a memtest to rule that out.

Bad DIMM is unlikely to cause random ASCII in memory. That's more like a
bad DMA or a buffer overflow in some driver. I would look for a unique
driver that user is using.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only
