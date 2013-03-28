From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after
 loopback down-up
Date: Thu, 28 Mar 2013 20:17:08 +0530
Message-ID: <CAHPKR9J4vmPp6SFn-betmb6GLimZE6dRf0Tapeu5jzyUJ=vK6Q@mail.gmail.com>
References: <CAHPKR9KE4LT_AEzUZ8cuJwBeMEEu0Ppe+jjynFQk7+N-A4YUmQ@mail.gmail.com>
	<1364478265.15753.42.camel@edumazet-glaptop>
	<1364478316.15753.43.camel@edumazet-glaptop>
	<CAHPKR9L4Y0=cbH7w_iZ20CBsH=nt4UuZwyBvDOMSrMmM_sJt1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:49908 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752893Ab3C1OrJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 10:47:09 -0400
Received: by mail-we0-f180.google.com with SMTP id r5so5410392wey.39
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 07:47:08 -0700 (PDT)
In-Reply-To: <CAHPKR9L4Y0=cbH7w_iZ20CBsH=nt4UuZwyBvDOMSrMmM_sJt1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 28, 2013 at 7:34 PM, Balakumaran Kannan
<kumaran.4353@gmail.com> wrote:
> On Thu, Mar 28, 2013 at 7:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2013-03-28 at 06:44 -0700, Eric Dumazet wrote:
>>
>>> __in6_dev_get() should be OK.
>>
>> more exactly : __in_dev_get_rtnl()
>>
>>
>>
>
> Thank you for your comments. I'll update the patch and send it.

As __in_dev_get_rtnl returns IPv4 specific data (ip_ptr), we have to
use __in6_dev_get to get IPv6 specific data (ip6_ptr).
