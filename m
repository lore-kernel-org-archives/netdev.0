From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: NAPI and TX
Date: Sat, 09 May 2009 14:27:40 +0200
Message-ID: <m3hbzuv4ub.fsf@intrepid.localdomain>
References: <m31vqzwzae.fsf@intrepid.localdomain>
	<20090508.144412.201441401.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:32815 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbZEIM1m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 May 2009 08:27:42 -0400
In-Reply-To: <20090508.144412.201441401.davem@davemloft.net> (David Miller's message of "Fri\, 08 May 2009 14\:44\:12 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> Many multiqueue drivers do exactly this.  NIU is but one example.
>
> Every discrete event from the chip which can generate discrete
> interrupts, uses a unique NAPI context.
>
> If a single interrupt is used to indicate RX and TX, using seperate
> NAPI contexts is not advisable.  It's just going to add overhead.

Great. Ben, David, Eric, thanks. I will try to use this.
-- 
Krzysztof Halasa
