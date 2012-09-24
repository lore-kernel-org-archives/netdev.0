From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next v4 0/1] Add support of ECMPv6
Date: Mon, 24 Sep 2012 14:28:40 +0200
Message-ID: <506051F8.8010209@6wind.com>
References: <20120920.171525.2005584636029506440.davem@davemloft.net> <1348221545-14747-1-git-send-email-nicolas.dichtel@6wind.com> <20120921.134833.1294721941180523200.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bernat@luffy.cx, netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:56787 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877Ab2IXM2o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 08:28:44 -0400
Received: by eekb15 with SMTP id b15so177231eek.19
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 05:28:43 -0700 (PDT)
In-Reply-To: <20120921.134833.1294721941180523200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 21/09/2012 19:48, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Fri, 21 Sep 2012 11:59:04 +0200
>
>> v4: remove compilation options to choose multipath algorithm for nex=
t hop
>>      selection. Now the choice can be done at run time via
>>      /proc/sys/net/ipv6/route/multipath_algorithm
>
> Please specify this in the routing configuration protocol, rather tha=
n
> via some obscure procfs file.
Just to be sure to understand, the goal is to configure the algorithm w=
hen the=20
route is added? Thus, resurrecting RTA_MP_ALGO and having one algo per =
route?
