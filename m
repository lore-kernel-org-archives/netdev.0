From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 0/7] Allow to monitor multicast cache event via
 rtnetlink
Date: Tue, 04 Dec 2012 21:02:27 +0100
Message-ID: <50BE56D3.2030704@6wind.com>
References: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com> <20121204.130914.1457976839967676240.davem@davemloft.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:41348 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436Ab2LDUCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 15:02:30 -0500
Received: by mail-we0-f174.google.com with SMTP id x10so1716206wey.19
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2012 12:02:29 -0800 (PST)
In-Reply-To: <20121204.130914.1457976839967676240.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/12/2012 19:09, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Date: Tue,  4 Dec 2012 12:13:34 +0100
>
>> The goal of this serie is to be able to monitor multicast activities=
 via
>> rtnetlink.
>>
>> The main changes are:
>>   - when user dumps mfc entries it now get all entries, included the=
 unresolved
>>     cache.
>>   - kernel sends rtnetlink when it adds/deletes mfc entries.
>>
>> As usual, the patch against iproute2 will be sent once the patches a=
re included and
>> net-next merged. I can send it on demand.
>
> This looks good, applied, thanks Nicolas.
>
> The one thing I worry about are those 64-bit statistics.  I fear that=
 they
> not be 64-bit aligned in the final netlink message.  This matters on =
cpus
> that trap on unaligned loads/stores, such as sparc and MIPS.
>
> Can you validate this?
>
I can have a try on a tile platform. I don't have access to sparc or mi=
ps.
