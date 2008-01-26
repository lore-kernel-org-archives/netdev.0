From: "Alon Bar-Lev" <alon.barlev@gmail.com>
Subject: Re: iproute2 (addr flush) infinite loop when unprivileged users
Date: Sat, 26 Jan 2008 23:48:03 +0200
Message-ID: <9e0cf0bf0801261348r6857403eo344ce0679d4b469b@mail.gmail.com>
References: <9e0cf0bf0801251500u388b9a5dxda92d6d1e3d86233@mail.gmail.com>
	 <20080125161259.0356c990@deepthought>
	 <9e0cf0bf0801251622w203c515fn80cba5f233bd599d@mail.gmail.com>
	 <9e0cf0bf0801260058s797d2ea3r7af013d0957554d8@mail.gmail.com>
	 <20080126111931.69e579c1@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:3446 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754490AbYAZVsH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jan 2008 16:48:07 -0500
Received: by ug-out-1314.google.com with SMTP id z38so724221ugc.16
        for <netdev@vger.kernel.org>; Sat, 26 Jan 2008 13:48:03 -0800 (PST)
In-Reply-To: <20080126111931.69e579c1@deepthought>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/26/08, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > iptunnel.c:(.text+0x51c): undefined reference to `__constant_htons'
> > iptunnel.o:iptunnel.c:(.text+0x535): more undefined references to
> > `__constant_htons' follow
> > collect2: ld returned 1 exit status
> > make[1]: *** [ip] Error 1
>
> This is defined via:
>   /usr/i!vinclude/linux/ip.h
>   #include <asm/byteorder.h>

Trace down the problem to Gentoo patch.
Sorry.

All working now!
Thanks!

Alon.
