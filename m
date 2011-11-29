From: Yuchung Cheng <ycheng@google.com>
Subject: Re: is non-inheritance of congestion control algorithm from the
 listen socket a bug or a feature?
Date: Tue, 29 Nov 2011 13:20:58 -0800
Message-ID: <CAK6E8=djWDn=ZvD0XLxex3vOfsDjCT64k+DwDSNp6+tLbPen2A@mail.gmail.com>
References: <4ED53AA1.9090800@hp.com> <1322600212.2596.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:62144 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756710Ab1K2VVU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 16:21:20 -0500
Received: by qyk4 with SMTP id 4so2029361qyk.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 13:21:19 -0800 (PST)
In-Reply-To: <1322600212.2596.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2011 at 12:56 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 29 novembre 2011 =E0 12:03 -0800, Rick Jones a =E9crit :
>
>> Is the non-inheritance of the congestion control algorithm a bug or =
a
>> feature?
>
> IMHO its a bug.
>
> Can you provide a fix ?
>
> Thanks !
I actually think it's a feature :)

I find it awkward to set CC on listening socket. And current document
defines the sysctl well

tcp_congestion_control - STRING
        Set the congestion control algorithm to be used for new
        connections. The algorithm "reno" is always available, but
        additional choices may be available based on kernel configurati=
on.
        Default is set as part of kernel configuration.
