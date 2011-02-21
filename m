From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Sun, 20 Feb 2011 22:01:00 -0800
Message-ID: <4D61FF9C.3080208@redfish-solutions.com>
References: <4B4CE2B8.1040702@redfish-solutions.com>	<20100112.130355.144803575.davem@davemloft.net>	<4B9943A4.8040606@redfish-solutions.com>	<20100311.112941.177105216.davem@davemloft.net> <m3tyslyej6.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	torsten.schmidt@s2006.tu-chemnitz.de, netdev@vger.kernel.org
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:46760 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754210Ab1BUGUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Feb 2011 01:20:49 -0500
In-Reply-To: <m3tyslyej6.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/12/10 3:18 AM, Benny Amorsen wrote:
> David Miller<davem@davemloft.net>  writes:
>
>> Look, this doesn't work.  QoS handling and policy belongs in the
>> egress point to the network, it's the only way to control this
>> properly and prevent abuse.
> First, QoS is important even within the network. Modern switches come
> pre-configured with sane defaults which ensure that e.g. EF marked
> packets get priority over non-EF-marked packets. Cisco, HP, and
> Linksys-Cisco at least provide a decent out-of-the-box configuration.
>
> This can obviously be abused, but the solution there is the same as in
> network abuses: Either apply the LART or change the configuration of the
> switches to be less trusting. We haven't, so far, had a customer where
> the LART was necessary, much less had to reconfigure a switch.
>
> So why not let Linux provide the same out-of-the-box experience as the
> switches do? If the trust is abused Linux provides lots of tools to make
> it less trusting or even to punish the abusers.
>
>
> /Benny

For those who want to use DiffServ as the out-of-the-box default configuration, and trust the marking on their traffic, I don't understand why certain folks are so adamant about not supporting this.

Torsten's patch to allow rt_tos2priority() to use IPTOS_PRECEDENCE() instead seemed reasonable.

Especially in a network using 802.1p or 802.1q encapsulation.


