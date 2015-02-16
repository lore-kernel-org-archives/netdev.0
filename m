From: Fan Du <fengyuleidian0615@gmail.com>
Subject: Re: [PATCH net-next 1/3] ipv4: Raise tcp PMTU probe mss base size
Date: Mon, 16 Feb 2015 13:15:54 +0800
Message-ID: <54E17D0A.5050604@gmail.com>
References: <1423815405-32644-1-git-send-email-fan.du@intel.com> <1423815405-32644-2-git-send-email-fan.du@intel.com> <54DDC8B1.1050307@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: yzhu1 <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:56178 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbbBPFUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2015 00:20:31 -0500
Received: by mail-pa0-f53.google.com with SMTP id lf10so32623756pab.12
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 21:20:30 -0800 (PST)
In-Reply-To: <54DDC8B1.1050307@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2015=E5=B9=B402=E6=9C=8813=E6=97=A5 17:49, yzhu1 =E5=86=99=E9=
=81=93:
> backward compatible? :-D

yes, it will be auto tuned back in black hole detecting path.
Also user could adjust the base size through /proc/sys/net/ipv4/tcp_bas=
e_mss
for optimal configuration.

> Zhu Yanjun
> On 02/13/2015 04:16 PM, Fan Du wrote:
>> Quotes from RFC4821 7.2.  Selecting Initial Values
>>
>>     It is RECOMMENDED that search_low be initially set to an MTU siz=
e
>>     that is likely to work over a very wide range of environments.  =
Given
>>     today's technologies, a value of 1024 bytes is probably safe eno=
ugh.
>>     The initial value for search_low SHOULD be configurable.
>>
>> Moreover, set a small value will introduce extra time for the search
>> to converge. So set the initial probe base mss size to 1024 Bytes.
>>
>> Signed-off-by: Fan Du <fan.du@intel.com>
>> ---
