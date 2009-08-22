From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: E100 RX ring buffers continued...
Date: Sat, 22 Aug 2009 17:32:35 +0200
Message-ID: <m34orzj23w.fsf@intrepid.localdomain>
References: <m38whchrer.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:50734 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754943AbZHVPcf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Aug 2009 11:32:35 -0400
In-Reply-To: <m38whchrer.fsf@intrepid.localdomain> (Krzysztof Halasa's message of "Sat\, 22 Aug 2009 16\:09\:00 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa <khc@pm.waw.pl> writes:

> There is also apparently unsupported and mostly undocumented "flexible
> mode". The question to Intel's experts: can the flexible mode be used
> anyway? I can write the code, but need info about eg. the data
> structures (RFD, how does it work in flexible mode) and a confirmation
> the silicon (or maybe which silicon) will work with it.

I can see there is some "erratum" in 82559 related to flexible RX mode.
It seems we're not affected, though - it requires more than 1 RBD (per
RFD I hope) for the problem to happen.

Do I get it right?
-- 
Krzysztof Halasa
