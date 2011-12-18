From: Matt Ginzton <matt@ginzton.net>
Subject: Re: reproducible kernel freeze using r8169 in Linux 3.0
Date: Sun, 18 Dec 2011 01:40:55 -0800
Message-ID: <1484924F-90E7-40FE-B066-3955842F2B71@ginzton.net>
References: <63CE35CA-7DD6-41EC-A745-6BA776D8C5E3@ginzton.net> <20111218083212.GA28286@electric-eye.fr.zoreil.com>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:40697 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379Ab1LRJk7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2011 04:40:59 -0500
Received: by iaeh11 with SMTP id h11so6851045iae.19
        for <netdev@vger.kernel.org>; Sun, 18 Dec 2011 01:40:58 -0800 (PST)
In-Reply-To: <20111218083212.GA28286@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Dec 18, 2011, at 12:32 AM, Francois Romieu wrote:

> Please grep for a XID line in dmesg and send it so we can figure the
> specific revision of your chipset (lspci can not figure it).
> 
> If it says something like "blah blah XID 1c4...", you should give current
> -rc a try (who shouldn't ?).

Hey, thanks for getting back so fast.

XID 1c4000c0. (And it says "RTL8168c/8111c" in this line, not the 8168B that lspci claimed).

I just found https://lkml.org/lkml/2011/12/1/399. It looks like you've had a handle on this problem since the beginning of December? http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=811fd3010cf512f2e23e6c4c912aad54516dc706 looks promising.

thanks,

Matt
