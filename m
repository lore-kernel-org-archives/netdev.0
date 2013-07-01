From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/ptp/Kconfig: add "depends on HAS_IOMEM" for 'PTP_1588_CLOCK_PCH'
Date: Mon, 01 Jul 2013 09:34:45 +0800
Message-ID: <51D0DCB5.5060106@asianux.com>
References: <51CB8CB7.6010006@asianux.com> <20130628.212311.1348427834856668120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, netdev@vger.kernel.org, richard@nod.at,
	geert@linux-m68k.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:12945 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751678Ab3GABfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jun 2013 21:35:39 -0400
In-Reply-To: <20130628.212311.1348427834856668120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2013 12:23 PM, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Thu, 27 Jun 2013 08:52:07 +0800
> 
>> > @@ -73,6 +73,7 @@ config DP83640_PHY
>> >  config PTP_1588_CLOCK_PCH
>> >  	tristate "Intel PCH EG20T as PTP clock"
>> >  	depends on X86 || COMPILE_TEST
> This "depends on X86 || COMPILE_TEST" does not exist in either 'net' or 'net-next'.
> Please submit your patches against a clean checkout of the networking GIT tree,
> rather than something else such as linux-next.

Oh, really it is, It is my fault (originally I get mail address from
"./scripts/get_maintainers.pl", but not give additional check on it).

For your information (or implicit suggestion), if one module wants to
request 'COMPILE_TEST', the platforms (or asm-generic) is recommended to
try to support it.

It seems I still have the chance to continue discuss about it with
platform guys. ;-)

Thanks.
-- 
Chen Gang
