From: Christophe Ngo Van Duc <cngovanduc@gmail.com>
Subject: Re: bnx2/5709: Strange interrupts spread
Date: Thu, 8 Jul 2010 17:06:44 -0300
Message-ID: <AANLkTim3_Gge_neL1v5VTWH-k1x6oAqZVNpu7GFs5nGl@mail.gmail.com>
References: <AANLkTiniNNPV9ztxXHtX4np7PIZabkm0I4v5O29chf8i@mail.gmail.com>
	<1278104311.11828.12.camel@HP1>
	<AANLkTimTcqANb3HQuC1W6VHWTh0ixO1lXAmVrmP6OZy2@mail.gmail.com>
	<AANLkTillLjztYe7mmyO_LoTXavDtTd2nsaAsd22z0dG-@mail.gmail.com>
	<4C326318.8050006@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60645 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438Ab0GHUGq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:06:46 -0400
Received: by wyf23 with SMTP id 23so901411wyf.19
        for <netdev@vger.kernel.org>; Thu, 08 Jul 2010 13:06:44 -0700 (PDT)
In-Reply-To: <4C326318.8050006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Traffic is IP no doubt about that. Lots of TCP and UDP traffic. I can
provide a very short pcap if you want (lots of traffic so pcap can be
big really quickly).

- The 2 interfaces that have this problems are running in promiscuous
mode (without having an assiged IP address to the interface) inside a
linux bridge interface (br0), but the traffic that is bridged is IP.

- The other 2 that works correctly: are not in promiscuous and have an
IP assigned to the network card.

So I am thinking that for some reason the RSS is activating only when
a specific configuration is set on the interface but not just on if it
is IP traffic or not.

Best Regards,
Christophe.

On Mon, Jul 5, 2010 at 7:56 PM, Rick Jones <rick.jones2@hp.com> wrote:
> Christophe Ngo Van Duc wrote:
>>
>> Is it a requirement that the interface has an IP address for the TX
>> and RX hash to work?
>
> At the risk of typing into Michael's keyboard, chances are, what the NIC
> does is follow Microsoft's specs for RSS, which as far as I can tell,
> discusses hashing either just on the IP addresses (v4 or v6) or the IP
> addresses and TCP port numbers, so unless Broadcom has an
> enhancement/extension, if the traffic arriving is not TCP/IP and not
> multiple connections, it probably does not get spread-out.
>
> rick jones
>
