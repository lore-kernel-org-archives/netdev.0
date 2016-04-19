From: Yuki Machida <machida.yuki@jp.fujitsu.com>
Subject: Re: Fwd: Re: Section 4 No. 9,10 Failed was occurred by IPv6 Ready
 Logo Conformance Test
Date: Tue, 19 Apr 2016 17:45:35 +0900
Message-ID: <5715F02F.2010609@jp.fujitsu.com>
References: <57020D23.9010403@jp.fujitsu.com>
 <5710AAA3.2020703@jp.fujitsu.com>
 <293867211.2746.1460728775752@office.mailbox.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hannes@stressinduktion.org, rongqing.li@windriver.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm03.jp.fujitsu.com ([202.219.69.170]:51649 "EHLO
	mgwkm03.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373AbcDSIpj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 04:45:39 -0400
Received: from m3050.s.css.fujitsu.com (msm.b.css.fujitsu.com [10.134.21.208])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 8B3EBAC024F
	for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 17:45:35 +0900 (JST)
In-Reply-To: <293867211.2746.1460728775752@office.mailbox.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hagen,

On 2016=E5=B9=B404=E6=9C=8815=E6=97=A5 22:59, Hagen Paul Pfeifer wrote:
>> On April 15, 2016 at 10:47 AM Yuki Machida <machida.yuki@jp.fujitsu.=
com> wrote:
>>
>>>> commit 9d289715eb5c252ae15bd547cb252ca547a3c4f2
>>>> Author: Hagen Paul Pfeifer <hagen@jauu.net>
>>>> Date: Thu Jan 15 22:34:25 2015 +0100
>>>>
>>>>        ipv6: stop sending PTB packets for MTU < 1280
>>>>
>>>>        Reduce the attack vector and stop generating IPv6 Fragment =
Header for
>>>>        paths with an MTU smaller than the minimum required IPv6 MT=
U
>>>>        size (1280 byte) - called atomic fragments.
>>>>
>>>>        See IETF I-D "Deprecating the Generation of IPv6 Atomic Fra=
gments" [1]
>>>>        for more information and how this "feature" can be misused.
>>>>
>>>>        [1]
>>>> https://tools.ietf.org/html/draft-ietf-6man-deprecate-atomfrag-gen=
eration-00
>>>>
>>>>        Signed-off-by: Fernando Gont <fgont@si6networks.com>
>>>>        Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
>>>>        Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>>>        Signed-off-by: David S. Miller <davem@davemloft.net>
>>>
>>> I will try.
>>
>> I confirmed that v4.1.20 revert above patch is passed Section 4 No. =
9 and 10 testcases
>> in IPv6 Ready Logo Conformance Test.
>> I can't immediately revert above patch from v4.6-rc1 by implementati=
on has changed.
>
> is it to please a conforming test tool or fix "revert 9d289715eb5c2" =
a real problem? If so: which problem do you have with 9d289715eb5c2 or =
draft-ietf-6man-deprecate-atomfrag-generation-06?
Thank you for your reply.
I was wrong.

That real problem may not be 9d289715eb5c2,
Because Roy said "TAHI should be updated".

But I don't understand that real problem is in Test Tool or draft-ietf-=
6man-deprecate-atomfrag-generation-06.
I am conforming it.

Regards,
Yuki Machida
>
> Hagen
>
