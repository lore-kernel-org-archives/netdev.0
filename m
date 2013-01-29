From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [PATCH 2/2] drivers: net:ethernet: cpsw: add support for VLAN
Date: Tue, 29 Jan 2013 17:39:02 +0530
Message-ID: <5107BBDE.7030401@ti.com>
References: <1359403945-28585-1-git-send-email-mugunthanvnm@ti.com>  <1359403945-28585-3-git-send-email-mugunthanvnm@ti.com> <1359452926.4336.1.camel@coredoba.hi.pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>
To: =?UTF-8?B?SmFuIEzDvGJiZQ==?= <jlu@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:60649 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753024Ab3A2MKL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 07:10:11 -0500
In-Reply-To: <1359452926.4336.1.camel@coredoba.hi.pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/29/2013 3:18 PM, Jan L=C3=BCbbe wrote:
> On Tue, 2013-01-29 at 01:42 +0530, Mugunthan V N wrote:
>> --- a/Documentation/devicetree/bindings/net/cpsw.txt
>> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
>> @@ -24,6 +24,8 @@ Required properties:
>>   Optional properties:
>>   - ti,hwmods            : Must be "cpgmac0"
>>   - no_bd_ram            : Must be 0 or 1
>> +- default_vlan         : Specifies Default VLAN for non tagged pack=
ets
>> +                         ALE processing
> This does not seem to be a property of the hardware. Could there be a
> reasonable default for it?
>
> Regards,
> Jan
Jan

In VLAN aware mode, ALE always process only VLAN tagged packets. Even=20
untagged packets
In hardware you can use any VLAN id for default (non tagged packet)=20
filtering.

Regards
Mugunthan V N
