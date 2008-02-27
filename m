From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 driver compatibility with rtl8168 [need confirm]
Date: Wed, 27 Feb 2008 23:11:33 +0100
Message-ID: <20080227221133.GB17759@electric-eye.fr.zoreil.com>
References: <a37929f0802251403q36ef6306wa30298dbded0d8ed@mail.gmail.com> <20080226201441.GA15796@electric-eye.fr.zoreil.com> <a37929f0802270450x7318a276o1789533e7224b123@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Miroslav Kratochvil <exa.exa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38401 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751583AbYB0W3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 17:29:49 -0500
Content-Disposition: inline
In-Reply-To: <a37929f0802270450x7318a276o1789533e7224b123@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Miroslav Kratochvil <exa.exa@gmail.com> :
[...]
> Well I would be happy if I had "reports", it basically looks like that
> someone complains on IRC and this fixes his problem. No kernel dumps
> and/or logs can be obtained (because of hard freeze). If you wanted
> some information about the machines, please specify what exactly do
> you want to see ("classic" logs like dmesg tell nothing. :( )

It would tell what the version of their kernel is, wether it's 64 bit
or not, etc. It (dmesg/lspci) helps to identify patterns. I don't even
speak of the binary-only stuff that people routinely use.

[...]
> exa@exabook ~ $ dmesg |grep RTL8
> [   11.043631] eth0: RTL8168b/8111b at 0xffffc2000002a000,
> 4c:00:10:3b:83:ad, XID 38000000 IRQ 11

Ok.

> ...also, notice that #defined buffer sizes are the only major
> difference between kernel and Realtek's r8168 driver.

Hardly. I have read version 8.004 of Realtek's driver.

Can you try to see if the fix is enough when faced with a stream
of packets from pktgen ? 

-- 
Ueimor
