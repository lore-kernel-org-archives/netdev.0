From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Tue, 24 Jul 2007 03:33:41 -0400
Message-ID: <46A5AB55.90007@garzik.org>
References: <20070723.210748.63127793.davem@davemloft.net> <20070724071201.GA7134@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, rusty@rustcorp.com.au
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53700 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754015AbXGXHdq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 03:33:46 -0400
In-Reply-To: <20070724071201.GA7134@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> David Miller <davem@davemloft.net> :
> [...]
>> I also didn't play with turning off NAPI in kconfig where drivers
>> allow that, can we just get rid of that crap already? :-/
> 
> Would it be accepted for 2.6.23 or must it be considered post-2.6.23 ?

The merge window is closed, so not 2.6.23.

The cases where Kconfig allows selection of NAPI-or-not is generally 
either (a) the author considers one path new and relatively unproven or 
(b) the author has not bothered to figure out which is the best choice, 
and instead just offers both rather than doing the legwork to find out.

Either way, individual cases must be examined and it is not necessarily 
just a cleanup.

	Jeff



