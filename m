From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: NAPI and TX
Date: Fri, 08 May 2009 14:32:25 +0200
Message-ID: <m31vqzwzae.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:41259 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752814AbZEHMc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2009 08:32:26 -0400
Received: from intrepid.localdomain (intrepid.localdomain [10.0.0.2])
	by khc.piap.pl (Postfix) with ESMTP id 7DDBA4F023
	for <netdev@vger.kernel.org>; Fri,  8 May 2009 14:32:25 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Could NAPI or something similar be used for TX in addition to RX?
Perhaps some driver already does that?

I'm specifically thinking of IXP4xx Ethernet (and possibly WAN), those
are 266-667 MHz ARM XScale CPUs and the interrupts handling just
transmitted sk_buffs are a pain. Could I delay those interrupts
somehow?
-- 
Krzysztof Halasa
