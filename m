From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Thu, 24 Apr 2008 15:39:47 +0200
Message-ID: <m3mynj74nw.fsf@maximus.localdomain>
References: <m3iqy8f57m.fsf@maximus.localdomain>
	<20080423.180849.240014014.davem@davemloft.net>
	<m3r6cv75xq.fsf@maximus.localdomain>
	<20080424.063006.153647297.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, paulkf@microgate.com, jchapman@katalix.com,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757946AbYDXNj6@vger.kernel.org>
In-Reply-To: <20080424.063006.153647297.davem@davemloft.net> (David Miller's message of "Thu\, 24 Apr 2008 06\:30\:06 -0700 \(PDT\)")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> writes:

> My current plan is to add an "official" mid-layer pointer for
> these purposes.  So that the bug can have a simple fix while
> we think about how better to handle this longer term.

That would be great first step.

Though we will have to abandon syncppp use anyway, at least for
generic HDLC (I don't care much about the old ISA drivers).
-- 
Krzysztof Halasa
