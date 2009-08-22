From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: E100 RX ring buffers continued...
Date: Sat, 22 Aug 2009 16:09:00 +0200
Message-ID: <m38whchrer.fsf@intrepid.localdomain>
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
Received: from khc.piap.pl ([195.187.100.11]:33881 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932141AbZHVOJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Aug 2009 10:09:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

E100 RX buffers seem more problematic than I though.
The descriptor doesn't contain the address of the data buffer. Instead,
the descriptor is to be followed by the data buffer immediately. It's
not only the driver invention :-(

The manual mentions it's the only mode supported, aka "simplified mode".
There is also apparently unsupported and mostly undocumented "flexible
mode". The question to Intel's experts: can the flexible mode be used
anyway? I can write the code, but need info about eg. the data
structures (RFD, how does it work in flexible mode) and a confirmation
the silicon (or maybe which silicon) will work with it.

TIA.
-- 
Krzysztof Halasa
