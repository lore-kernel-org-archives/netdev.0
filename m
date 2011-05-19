From: Micha Nelissen <micha@neli.hopto.org>
Subject: Re: [PATCH v3] ipconfig wait for carrier
Date: Thu, 19 May 2011 21:39:25 +0200
Message-ID: <4DD571ED.8060400@neli.hopto.org>
References: <20110518.181427.1228926976939865196.davem@davemloft.net>	<1305819120.3271.3.camel@dcbw.foobar.com>	<4DD56E7A.3010901@neli.hopto.org> <20110519.153507.578609630787612821.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dcbw@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from edu-smtp-01.edutel.nl ([88.159.1.175]:35386 "EHLO
	edu-smtp-01.edutel.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934417Ab1ESTkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 15:40:00 -0400
In-Reply-To: <20110519.153507.578609630787612821.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Micha Nelissen <micha@neli.hopto.org>
> Date: Thu, 19 May 2011 21:24:42 +0200
> 
>> Even if link is "fake up" by driver and not actually up after 10 msecs,
>> things will continue to work (eventually), after a second, just like now.
> 
> But this eats one of the CONF_SEND_RETRIES attempts, which is only 6.

Right. So an alternative could be to increase this to 7, or do you
prefer leaving the 1 sec timeout untouched?

Micha
