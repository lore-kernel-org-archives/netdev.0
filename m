From: =?ISO-8859-1?Q?Richard_R=F6jfors?= <richard.rojfors@pelagicore.com>
Subject: Re: [PATCH] ks8842: Add module param for setting mac address
Date: Mon, 19 Apr 2010 08:46:58 +0200
Message-ID: <4BCBFC62.8010200@pelagicore.com>
References: <1271611557.24099.11.camel@debian>	<20100418.211800.112605815.davem@davemloft.net>	<4BCBF53D.1040800@pelagicore.com> <20100418.233631.115927208.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b11.telenor.se ([62.127.194.20]:55255 "EHLO
	smtprelay-b11.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751877Ab0DSGrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 02:47:43 -0400
Received: from ipb3.telenor.se (ipb3.telenor.se [195.54.127.166])
	by smtprelay-b11.telenor.se (Postfix) with ESMTP id 9FCCDE3F4
	for <netdev@vger.kernel.org>; Mon, 19 Apr 2010 08:47:01 +0200 (CEST)
In-Reply-To: <20100418.233631.115927208.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/19/2010 08:36 AM, David Miller wrote:
> From: Richard R=F6jfors<richard.rojfors@pelagicore.com>
> Date: Mon, 19 Apr 2010 08:16:29 +0200
>
>> I posted a new patch where the MAC address is passed via
>> platform data, hope that's an accepted way.
>
> I saw also that you mentioned that there is no real
> way to probe this information.
>
> Therefore I worry that your plan might be to simply
> use some kernel command line or module option somewhere
> else to fill in this platform_device value.
>
> Is that what you plan to do?

In the lab; yes.
In the end, there will be a flash available to store
system wide parameters.

--Richard
