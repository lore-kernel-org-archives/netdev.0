From: Daniel Hazelton <dhazelton@enter.net>
Subject: Re: [PATCH] sky2: Lock transmit queue while disabling device
Date: Thu, 31 Dec 2009 11:15:33 -0500
Message-ID: <200912311115.33456.dhazelton@enter.net>
References: <4B3C8323.1080301@ring3k.org> <4B3CCA17.5020707@majjas.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mike McCormack <mikem@ring3k.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, flyboy@gmail.com
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from keil-draco.com ([216.193.185.50]:53642 "EHLO
	mail.keil-draco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486AbZLaQPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 11:15:39 -0500
In-Reply-To: <4B3CCA17.5020707@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 31 December 2009 10:58:15 am Michael Breuer wrote:
> This doesn't solve the issue on my system. Just ran a test - same
> errors. I don't think that the under-load errors I'm seeing involve
> sky2_detatch. I'm thinking it's related to the dhcp AF_INTERNET fix that
> solved the lockup under load - that something outside of sky2 is
> corrupting an skb.

and I am unable to try because I have never had the time - or the free machine 
- to narrow down what, exactly is causing a similar crash here. It appears, 
however, to be caused by some a**hole out there deciding to point a botnet at 
that server...

(at least... that's what has been going on each time the machine has gone 
down...)

DRH
