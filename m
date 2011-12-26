From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH 1/2] bna: Added flash sub-module and ethtool eeprom entry
 points.
Date: Mon, 26 Dec 2011 16:46:56 +0100
Message-ID: <4EF896F0.2090306@computer.org>
References: <B5EE62D80D50B84BB9E5174F7FCCE80A206BE39A24@HQ1-EXCH02.corp.brocade.com>	<1324721314.3860.11.camel@deadeye>	<4EF86253.3010108@computer.org> <20111226.101035.782817982749726680.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, kgudipat@Brocade.com,
	netdev@vger.kernel.org, adapter_linux_open_src_team@Brocade.com,
	rmody@Brocade.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay002.isp.belgacom.be ([195.238.6.175]:35603 "EHLO
	mailrelay002.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755707Ab1LZPrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Dec 2011 10:47:09 -0500
In-Reply-To: <20111226.101035.782817982749726680.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/26/2011 04:10 PM, David Miller wrote:
> From: Jan Ceuleers<jan.ceuleers@computer.org>
> Date: Mon, 26 Dec 2011 13:02:27 +0100
>> Is it OK to hold the RTNL lock for that length of time?
> No, because it means that no network configuration of any kind can
> occur during this time.
>
> Backbone routers need to perform hundreds of routing table updates per
> second, even more during major route flaps.  All of these would be
> blocked during your flash operation.
>
That's what I thought. Over to Krishna.
