From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: question about vrf-lite
Date: Thu, 7 Jan 2016 09:04:05 +0800
Message-ID: <CAJFZqHwpEeQce1SyqZLecehMa9hBKKc-J2r0WurAS+qRdXw_2w@mail.gmail.com>
References: <1452074022-11816-1-git-send-email-roy.qing.li@gmail.com>
	<568D3E3C.2030301@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:36282 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbcAGBEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 20:04:05 -0500
Received: by mail-qg0-f43.google.com with SMTP id e32so226910570qgf.3
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 17:04:05 -0800 (PST)
In-Reply-To: <568D3E3C.2030301@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> is it right?
>
>
> no. The above works fine for me. I literally copied and pasted all of the
> commands except the master ones which were adapted to my setup -- eth9 and
> eth11 for me instead of eth0 and eth1. tcpdump on N2, N3 show the right one
> is receiving packets based on which 'ping -I vrf<N>' is run.
>
> Do tables 5 and 6 have the right routes?


Thanks, David;

it is not VRF issue, it is my configuration issue about qemu;

I am testing VRF on qemu, and the issue/solution is same as issue
under below link

https://lists.gnu.org/archive/html/qemu-discuss/2014-06/msg00059.html

-Roy
