From: Matt Ginzton <matt@ginzton.net>
Subject: Re: reproducible kernel freeze using r8169 in Linux 3.0
Date: Sun, 1 Jan 2012 18:03:20 -0800
Message-ID: <DED183BB-B51D-4739-99B3-7E0B71897159@ginzton.net>
References: <63CE35CA-7DD6-41EC-A745-6BA776D8C5E3@ginzton.net> <20111218083212.GA28286@electric-eye.fr.zoreil.com>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55524 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751054Ab2ABCDX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2012 21:03:23 -0500
Received: by iaeh11 with SMTP id h11so28550286iae.19
        for <netdev@vger.kernel.org>; Sun, 01 Jan 2012 18:03:23 -0800 (PST)
In-Reply-To: <20111218083212.GA28286@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 18, 2011, at 12:32 AM, Francois Romieu wrote:

> Matt Ginzton <matt@ginzton.net> :
> [...]
>> Please let me know if I'm reporting this to the right place, or if there's
>> any other helpful info I can provide.
> 
> Please grep for a XID line in dmesg and send it so we can figure the
> specific revision of your chipset (lspci can not figure it).
> 
> If it says something like "blah blah XID 1c4...", you should give current
> -rc a try (who shouldn't ?).

Just to follow up on this old thread:

- my XID line says 1c4000c0
- I tried 3.2-rc7 kernel, and couldn't reproduce any problems at all -- not the complete system freeze from 3.0 kernels, nor the slow_path kernel warning and backtrace from 3.1 kernels. A big improvement indeed -- thank you.

I do note that TX performance as measured by pktgen is lower than r8168 -- with r8169 in 3.2-rc7 I see something like 455MB/sec and with r8168, IIRC, the number was closer to 800MB/sec. This may be a very artificial statistic, and isn't something I happen to care about and I'm certainly not going to use r8168 because of it, but it may be worth looking into?

cheers,

Matt
