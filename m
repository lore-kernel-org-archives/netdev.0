From: Pkun <serj.kalichev@gmail.com>
Subject: Re: [PATCH] Fix build system and configure script to use for cross
 build. Optional IPv6.
Date: Fri, 10 Dec 2010 21:13:28 +0300
Message-ID: <AANLkTikFHoMWybK8LWoSKzPhWjVEk1TUSypVsNxEq7nd@mail.gmail.com>
References: <1291995271-9912-1-git-send-email-serj.kalichev@gmail.com>
	<20101210081452.360e2689@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.212.179]:35702 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756849Ab0LJSN3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 13:13:29 -0500
Received: by pxi20 with SMTP id 20so1089737pxi.10
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 10:13:29 -0800 (PST)
In-Reply-To: <20101210081452.360e2689@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/12/10 Stephen Hemminger <shemminger@linux-foundation.org>:
> On Fri, 10 Dec 2010 18:34:31 +0300
> Serj Kalichev <serj.kalichev@gmail.com> wrote:
>
>> The Makefiles and configure script understand the external variables like
>> CC, CFLAGS, LDFLAGS etc. So it can be used for cross build easily. The
>> configure script use CC instead hardcoded gcc and search for the xtables
>> within specified SYSROOT but not on the host. Two checks were added. The
>> check for the IPv6 support and check for the Berkeley DB availability.
>> The iproute2 can be build without IPv6 now.
>>
>> Signed-off-by: Serj Kalichev <serj.kalichev@gmail.com>
>
> IPv6 support should not be optional.
>
>
> --
>

Why? I don't need an IPv6. Who need it - will switch it on. No problem

Sorry for duplication. I have subscribed to netdev list.
