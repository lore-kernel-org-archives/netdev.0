From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: NAPI and ->poll()
Date: Wed, 09 Jul 2008 01:00:44 +0200
Message-ID: <m31w24asmb.fsf@maximus.localdomain>
References: <m3vdzgfqv8.fsf@maximus.localdomain>
	<20080708.142450.171642381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from OSB1387.piap.pl ([195.187.100.11]:54819 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751801AbYGHXAq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 19:00:46 -0400
In-Reply-To: <20080708.142450.171642381.davem@davemloft.net> (David Miller's message of "Tue\, 08 Jul 2008 14\:24\:50 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> So, as you can see, if you consume the entire budget, your
> caller assumes that it still owns the NAPI context and it is
> still scheduled.  Otherwise, if less than the budget is consumed,
> you must netif_rx_complete().

Great. Thanks for the detailed info, David.
-- 
Krzysztof Halasa
