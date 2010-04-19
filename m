From: =?ISO-8859-1?Q?Richard_R=F6jfors?= <richard.rojfors@pelagicore.com>
Subject: Re: [PATCH] ks8842: Add module param for setting mac address
Date: Mon, 19 Apr 2010 08:16:29 +0200
Message-ID: <4BCBF53D.1040800@pelagicore.com>
References: <1271611557.24099.11.camel@debian> <20100418.211800.112605815.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b11.telenor.se ([62.127.194.20]:54715 "EHLO
	smtprelay-b11.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751555Ab0DSGrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 02:47:21 -0400
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-b11.telenor.se (Postfix) with ESMTP id 2F07CE292
	for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 08:16:31 +0200 (CEST)
In-Reply-To: <20100418.211800.112605815.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2010 06:18 AM, David Miller wrote:
> From: Richard R=F6jfors<richard.rojfors@pelagicore.com>
> Date: Sun, 18 Apr 2010 19:25:57 +0200
>
>> This patch adds a module parameter for setting the MAC address.
>>
>> To ensure this MAC address is used, the MAC address is written
>> after each hardware reset.
>>
>> Signed-off-by: Richard R=F6jfors<richard.rojfors@pelagicore.com>
>
> Your driver isn't unique, or special, and it doesn't need
> to do special things to handle this situation.

I posted a new patch where the MAC address is passed via
platform data, hope that's an accepted way.

Thanks,
--Richard
