From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Strange network timeouts w/ 2.6.30.5
Date: Fri, 21 Aug 2009 11:44:35 +0200
Message-ID: <m3d46plcvw.fsf@intrepid.localdomain>
References: <322550336.131250806883202.JavaMail.root@mail.holmansrus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Walt Holman <walt@holmansrus.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:55736 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755081AbZHUJog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 05:44:36 -0400
In-Reply-To: <322550336.131250806883202.JavaMail.root@mail.holmansrus.com> (Walt Holman's message of "Thu\, 20 Aug 2009 17\:21\:23 -0500 \(CDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Walt Holman <walt@holmansrus.com> writes:

> Would something like passing a mem=xx cmdline on x86_64 be sufficient to test this?

I think so, though I admit I don't remember using this personally since
the introduction of e820 RAM mapping support.
Dmesg will show if the memory is limited. For the swiotlb to effectively
disable no RAM > 0x100000000 may be used.

But this test isn't IMHO terribly important at this point - the driver
makes invalid use of the DMA API and it has to change. The test could
only explain _how_ exactly does it fail, we already know _why_ it does.
-- 
Krzysztof Halasa
