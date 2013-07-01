From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] drivers/ptp/Kconfig: add "depends on HAS_IOMEM" for 'PTP_1588_CLOCK_PCH'
Date: Mon, 01 Jul 2013 07:40:49 +0200
Message-ID: <51D11661.7040604@nod.at>
References: <51CB8CB7.6010006@asianux.com> <20130628.212311.1348427834856668120.davem@davemloft.net> <51D0DCB5.5060106@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, richardcochran@gmail.com,
	netdev@vger.kernel.org, geert@linux-m68k.org
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.ns.miles-group.at ([95.130.255.144]:1660 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750782Ab3GAFrp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 01:47:45 -0400
In-Reply-To: <51D0DCB5.5060106@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 01.07.2013 03:34, schrieb Chen Gang:
> On 06/29/2013 12:23 PM, David Miller wrote:
>> From: Chen Gang <gang.chen@asianux.com>
>> Date: Thu, 27 Jun 2013 08:52:07 +0800
>>
>>>> @@ -73,6 +73,7 @@ config DP83640_PHY
>>>>  config PTP_1588_CLOCK_PCH
>>>>  	tristate "Intel PCH EG20T as PTP clock"
>>>>  	depends on X86 || COMPILE_TEST
>> This "depends on X86 || COMPILE_TEST" does not exist in either 'net' or 'net-next'.
>> Please submit your patches against a clean checkout of the networking GIT tree,
>> rather than something else such as linux-next.
> 
> Oh, really it is, It is my fault (originally I get mail address from
> "./scripts/get_maintainers.pl", but not give additional check on it).
> 
> For your information (or implicit suggestion), if one module wants to
> request 'COMPILE_TEST', the platforms (or asm-generic) is recommended to
> try to support it.
> 
> It seems I still have the chance to continue discuss about it with
> platform guys. ;-)

David told you that your patch does not apply.
Not even Linus' tree has "depends on X86 || COMPILE_TEST".
Please adjust your patch.

Thanks,
//richard
