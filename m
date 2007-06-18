From: Patrick McHardy <kaber@trash.net>
Subject: Re: sky bugs in 2.6.22-rc5
Date: Mon, 18 Jun 2007 22:56:13 +0200
Message-ID: <4676F16D.3070100@trash.net>
References: <4676E1DD.1060007@trash.net>	<20070618130414.35801913@localhost.localdomain>	<4676E77E.4080707@trash.net>	<20070618132021.64b08836@localhost.localdomain>	<4676EE86.5010205@trash.net> <20070618134708.6be59348@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42295 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762633AbXFRU4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 16:56:15 -0400
In-Reply-To: <20070618134708.6be59348@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Mon, 18 Jun 2007 22:43:50 +0200
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>Unloading the driver (with your patch) crashed my box twice.
> 
> Was that under load or just idle?

Pretty much idle, maybe a few NTP broadcasts flying around.

>>I've
>>attached a log of loading the driver with debug=15, transmitting
>>a few packets, then setting it down and up again and trying to
>>transmit a few more packets (which didn't work).
>>
> 
> 
> What kind of switch.


Some ten year old noname 10/100 switch. But it also happens
with the cable pulled.

