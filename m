From: =?ISO-8859-1?Q?Fejes_J=F3zsef?= <jozsef.fejes@gmail.com>
Subject: Re: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Tue, 31 Dec 2013 12:27:46 +0100
Message-ID: <CALU-w99eT4TX0xHc_KZBoP_JFpEex-0B8iH3sb8wUMfO4WuOHg@mail.gmail.com>
References: <CALU-w9860x_rWhu35v50N39b8AxiPB_wOk1OUKdBr9eBLzEZFA@mail.gmail.com>
	<20131230233833.GA434@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:63553 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750Ab3LaL1r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Dec 2013 06:27:47 -0500
Received: by mail-wi0-f170.google.com with SMTP id hq4so16454945wib.5
        for <netdev@vger.kernel.org>; Tue, 31 Dec 2013 03:27:46 -0800 (PST)
In-Reply-To: <20131230233833.GA434@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

The paste is from 3.11.6 actually, but 3.12.6 produces the same
behavior. Nothing changed recently in my networking setup.
Immediately, when I plug in my laptop to that interface, the error is
produced, ifconfig on the machine shows that packets are sent out, but
I see no received packets in my laptop on the other end.

I haven't used that interface for quite some time, a year at most. I
keep up to date with the stable kernels, so a version change broke it,
but I'm not sure which. Would it be the best course of action if I
tried some older versions?

Best regards, Jozsef


On Tue, Dec 31, 2013 at 12:38 AM, Francois Romieu <romieu@fr.zoreil.com=
> wrote:
> Fejes J=F3zsef <jozsef.fejes@gmail.com> :
> [...]
>> I'm having the issue mentioned in the subject line with the latest
>> stable kernel, 3.12.6.
>>
>> This network controller is integrated into a D945GSEJT motherboard, =
dmesg info:
>
> It's thus an old setup (bridge included), nothing changed recently
> and it qualifies as a regression, right ?
>
> If so, wherefrom ?
>
> --
> Ueimor
