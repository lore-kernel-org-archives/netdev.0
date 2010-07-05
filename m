From: Rick Jones <rick.jones2@hp.com>
Subject: Re: bnx2/5709: Strange interrupts spread
Date: Mon, 05 Jul 2010 15:56:24 -0700
Message-ID: <4C326318.8050006@hp.com>
References: <AANLkTiniNNPV9ztxXHtX4np7PIZabkm0I4v5O29chf8i@mail.gmail.com>	<1278104311.11828.12.camel@HP1>	<AANLkTimTcqANb3HQuC1W6VHWTh0ixO1lXAmVrmP6OZy2@mail.gmail.com> <AANLkTillLjztYe7mmyO_LoTXavDtTd2nsaAsd22z0dG-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Christophe Ngo Van Duc <cngovanduc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:22055 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318Ab0GEW40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 18:56:26 -0400
In-Reply-To: <AANLkTillLjztYe7mmyO_LoTXavDtTd2nsaAsd22z0dG-@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christophe Ngo Van Duc wrote:
> Is it a requirement that the interface has an IP address for the TX
> and RX hash to work?

At the risk of typing into Michael's keyboard, chances are, what the NIC does is 
follow Microsoft's specs for RSS, which as far as I can tell, discusses hashing 
either just on the IP addresses (v4 or v6) or the IP addresses and TCP port 
numbers, so unless Broadcom has an enhancement/extension, if the traffic 
arriving is not TCP/IP and not multiple connections, it probably does not get 
spread-out.

rick jones
