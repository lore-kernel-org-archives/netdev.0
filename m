From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 driver crashes in 2.6.32.43
Date: Thu, 28 Jul 2011 14:23:28 +0200
Message-ID: <20110728122328.GA11424@electric-eye.fr.zoreil.com>
References: <20110724195831.GA8718@colin.search.kasperd.net> <20110724201626.GB24418@zoreil.com> <20110725103643.GA11135@colin.search.kasperd.net> <20110728070455.GA11251@electric-eye.fr.zoreil.com> <20110728084821.GA24125@colin.search.kasperd.net> <20110728105831.GA11385@electric-eye.fr.zoreil.com> <20110728114305.GA24549@colin.search.kasperd.net> <20110728115936.GC24549@colin.search.kasperd.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ivecera@redhat.com, hayeswang@realtek.com, gregkh@suse.de,
	netdev@vger.kernel.org
To: Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39230 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106Ab1G1Mj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 08:39:27 -0400
Content-Disposition: inline
In-Reply-To: <20110728115936.GC24549@colin.search.kasperd.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net> :
[...]
> But maybe the two interfaces are independent enough that I
> can run netconsole over one while triggering a crash on the
> other.

I am not exactly biased in favor of netconsole yet but go for
it if you are confortable with.

[...]
> It doesn't compile. It complains about netif_info and drv
> not being declared.

?

You can replace them with plain printk(KERN_{INFO/ERR} "S: ...).

What are you compiling the patch against ?

-- 
Ueimor
