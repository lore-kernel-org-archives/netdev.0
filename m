From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: Re: [PATCH] ip: find correct route for socket which is not bound (v2)
Date: Fri, 25 Sep 2015 08:54:30 +0800
Message-ID: <56049B46.6080908@oracle.com>
References: <1442822409-9799-1-git-send-email-wen.gang.wang@oracle.com>
 <20150924.142228.132445616196971304.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43618 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294AbbIYAxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 20:53:05 -0400
In-Reply-To: <20150924.142228.132445616196971304.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

=D4=DA 2015=C4=EA09=D4=C225=C8=D5 05:22, David Miller =D0=B4=B5=C0:
> From: Wengang Wang <wen.gang.wang@oracle.com>
> Date: Mon, 21 Sep 2015 16:00:09 +0800
>
>> This is the v2, comparing the v1, the changes is:
>>   * for loopback outbound device, it continue skipping cached route;
>>     for others, it goes through the cached route.
> There are many things I want you to clean up in your commit message.
>
>> For multi-cast, we should find valid route(thus get the meaniful pmt=
u) for
>> the package on the socket which is not bound to a device(sk_bound_de=
v_if
>> being 0) too.
> Please use the term "packet" rather than "package".  Gifts you receiv=
e
> from a friend might be in a "package", but data is sent onto a networ=
k
> inside of "packets".
>
>> A problem is hit that all multi-cast packages dropped by kernel(from=
 sender
> "multicast" is a single word.
>
>> host). The lower layer is IPoIB with MTU being 7000. And I was sendi=
ng 4096
>> length multi-cast  package. In side IPoIB the first send is dropped =
because
> "Inside" is one word.

Accepted, sorry for my bad English. I will re-post as you suggested.

thanks,
wengang
