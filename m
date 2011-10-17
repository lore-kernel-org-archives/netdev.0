From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: realtek 8168 driver problem
Date: Mon, 17 Oct 2011 22:57:47 +0200
Message-ID: <20111017205747.GA25571@electric-eye.fr.zoreil.com>
References: <CAFwXZv9pq+SZh7kY5kS3k9Jmnih9t++rvtuWvLH9VOAttE+RVw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: HacKurx <hackurx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53918 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754093Ab1JQVAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 17:00:41 -0400
Content-Disposition: inline
In-Reply-To: <CAFwXZv9pq+SZh7kY5kS3k9Jmnih9t++rvtuWvLH9VOAttE+RVw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HacKurx <hackurx@gmail.com> :
[...]
> A very annoying problem affects a large number of GNU/Linux distribution.
> Network card problem (with 8111/8168 chipset), As you can see:
[...]
> [    5.159689] r8169 0000:03:00.0: eth0: RTL8168b/8111b at 0xffffc9000178c000, 50:e5:49:52:8a:7f, XID 0c900800 IRQ 41

XID identifies your chipset as RTL_GIGA_MAC_VER_34. A recent r8169 kernel
driver would display something like :

[    x.xxxxxx] r8169 0000:03:00.0: eth0: RTL8168evl/8111evl at ...
                                         ^^^^^^^^^^^^^^^^^^

Your r8169 driver lacks support for the adequate chipset. Please try
current 3.1-rc. It should perform better.

-- 
Ueimor
