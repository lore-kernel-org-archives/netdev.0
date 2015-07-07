From: Matteo Croce <matteo@openwrt.org>
Subject: Re: [PATCH v2] add stealth mode
Date: Tue, 7 Jul 2015 17:24:07 +0200
Message-ID: <CAFnufp292vwyoSJKK6smF55cFerxbCC_5pg_9NbRsvnRC7VH6A@mail.gmail.com>
References: <CAFnufp059tojfKYBye4eayOCvNNkAE9w_s_6E-PiG-EYp9K0Gg@mail.gmail.com>
 <21611.1436179798@turing-police.cc.vt.edu> <559B7943.3070807@ladisch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Clemens Ladisch <clemens@ladisch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35130 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756969AbbGGPYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 11:24:48 -0400
In-Reply-To: <559B7943.3070807@ladisch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-07-07 9:01 GMT+02:00 Clemens Ladisch <clemens@ladisch.de>:
> Valdis.Kletnieks@vt.edu wrote:
>> On Thu, 02 Jul 2015 10:56:01 +0200, Matteo Croce said:
>>> Add option to disable any reply not related to a listening socket
>>
>> 2) You *do* realize that this isn't anywhere near sufficient in order
>> to actually make your machine "invisible", right?  (Hint: What *other*
>> packets can be sent to a machine to provoke a response?)
>
> Even worse: if you want to pretend that the entire machine is "not there",
> you must make the router in front on you reply with an ICMP "destination
> unreachable" message.

You can't do sometimes, like in DSL lines where the router in front of
you is an ISP owned DSLAM

-- 
Matteo Croce
OpenWrt Developer
