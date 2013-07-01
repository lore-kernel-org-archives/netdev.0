From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/ptp/Kconfig: add "depends on HAS_IOMEM" for 'PTP_1588_CLOCK_PCH'
Date: Mon, 01 Jul 2013 14:09:24 +0800
Message-ID: <51D11D14.8000706@asianux.com>
References: <51CB8CB7.6010006@asianux.com> <20130628.212311.1348427834856668120.davem@davemloft.net> <51D0DCB5.5060106@asianux.com> <51D11661.7040604@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, richardcochran@gmail.com,
	netdev@vger.kernel.org, geert@linux-m68k.org
To: Richard Weinberger <richard@nod.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:63356 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751008Ab3GAGKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 02:10:16 -0400
In-Reply-To: <51D11661.7040604@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2013 01:40 PM, Richard Weinberger wrote:
> Am 01.07.2013 03:34, schrieb Chen Gang:
>> > On 06/29/2013 12:23 PM, David Miller wrote:
>>> >> From: Chen Gang <gang.chen@asianux.com>
>>> >> Date: Thu, 27 Jun 2013 08:52:07 +0800
>>> >>
>>>>> >>>> @@ -73,6 +73,7 @@ config DP83640_PHY
>>>>> >>>>  config PTP_1588_CLOCK_PCH
>>>>> >>>>  	tristate "Intel PCH EG20T as PTP clock"
>>>>> >>>>  	depends on X86 || COMPILE_TEST
>>> >> This "depends on X86 || COMPILE_TEST" does not exist in either 'net' or 'net-next'.
>>> >> Please submit your patches against a clean checkout of the networking GIT tree,
>>> >> rather than something else such as linux-next.
>> > 
>> > Oh, really it is, It is my fault (originally I get mail address from
>> > "./scripts/get_maintainers.pl", but not give additional check on it).
>> > 
>> > For your information (or implicit suggestion), if one module wants to
>> > request 'COMPILE_TEST', the platforms (or asm-generic) is recommended to
>> > try to support it.
>> > 
>> > It seems I still have the chance to continue discuss about it with
>> > platform guys. ;-)
> David told you that your patch does not apply.
> Not even Linus' tree has "depends on X86 || COMPILE_TEST".
> Please adjust your patch.


Before send the patch, it is better to discuss the "asm-generic"
whether need consider 'COMPILE_TEST'.

config COMPILE_TEST
        bool "Compile also drivers which will not load"
        default n
        help
          Some drivers can be compiled on a different platform than they are
          intended to be run on. Despite they cannot be loaded there (or even
          when they load they cannot be used due to missing HW support),
          developers still, opposing to distributors, might want to build such
          drivers to compile-test them.

          If you are a developer and want to build everything available, say Y
          here. If you are a user/distributor, say N here to exclude useless
          drivers to be distributed.

I guess, 'COMPILE_TEST' is really useful for UML.

Thanks.
-- 
Chen Gang
