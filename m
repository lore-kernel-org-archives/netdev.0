From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Mass udp flow reboot linux with RealTek RTL-8169 Gigabit
Date: Sun, 13 Feb 2011 14:56:00 +0100
Message-ID: <20110213135600.GA11382@electric-eye.fr.zoreil.com>
References: <AANLkTin7GBSTcfZgr_9sNZ8CPMkW7Vstni+fs2v1-ink@mail.gmail.com> <1297581470.2510.18.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Ivan Vecera <ivecera@redhat.com>
To: Seblu <seblu@seblu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44444 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907Ab1BMN7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 08:59:34 -0500
Content-Disposition: inline
In-Reply-To: <1297581470.2510.18.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> :
> Le dimanche 13 f??vrier 2011 ?? 02:35 +0100, Seblu a ??crit :
[...]
> Some attempts were done to avoid a reset on some chipsets.
> 
> You could try latest linux-2.6 tree. This includes commits 
> 
> f60ac8e7ab7cbb413a0131d5665b053f9f386526 (r8169: prevent RxFIFO induced
> loops in the irq handler.)
> 
> 1519e57fe81c14bb8fa4855579f19264d1ef63b4 (r8169: RxFIFO overflow
> oddities with 8168 chipsets.)
> 
> b5ba6d12bdac21bc0620a5089e0f24e362645efd (r8169: use RxFIFO overflow
> workaround for 8168c chipset.)

If it still does not perform better, please include the XID line of
the r8169 driver from dmesg.

-- 
Ueimor
