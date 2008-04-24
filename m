From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Thu, 24 Apr 2008 06:30:06 -0700 (PDT)
Message-ID: <20080424.063006.153647297.davem@davemloft.net>
References: <m3iqy8f57m.fsf@maximus.localdomain>
	<20080423.180849.240014014.davem@davemloft.net>
	<m3r6cv75xq.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, paulkf@microgate.com, jchapman@katalix.com,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: khc@pm.waw.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48617
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757844AbYDXNaG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2008 09:30:06 -0400
In-Reply-To: <m3r6cv75xq.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krzysztof Halasa <khc@pm.waw.pl>
Date: Thu, 24 Apr 2008 15:12:17 +0200

> Anyway, I guess we should rather concentrate on what to do now with
> the thing. Perhaps you have some idea?

My current plan is to add an "official" mid-layer pointer for
these purposes.  So that the bug can have a simple fix while
we think about how better to handle this longer term.
