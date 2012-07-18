From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: link up, link down
Date: Wed, 18 Jul 2012 21:23:10 +0200
Message-ID: <20120718192310.GB14149@electric-eye.fr.zoreil.com>
References: <02b401cd64f9$115acc90$341065b0$@cl> <20120718173909.GA12524@electric-eye.fr.zoreil.com> <038001cd6512$613125c0$23937140$@cl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "J. Christopher Pereira" <kripper@imatronix.cl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52559 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755091Ab2GRTf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 15:35:59 -0400
Content-Disposition: inline
In-Reply-To: <038001cd6512$613125c0$23937140$@cl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

J. Christopher Pereira <kripper@imatronix.cl> :
[...]
> dmesg says "eth0: RTL8110s at 0xffffc2000067ec00, 00:4f:4a:10:1e:cf, XID
> 04000000 IRQ 16".

It's an old chipset (RTL_GIGA_MAC_VER_03). The PCI remove / rescan trick
may or may not work.

> > Building a modern kernel is strongly suggested if the hardware includes a
> recent 816x chipset.
> 
> Is there any particular patch I could apply and just recompile the driver?

Your kernel is more than three years old. It is not _that_ long but there
are ~182 r8169 patches between v2.6.30 and v3.4. There will still be a lot
even after the trivial ones are factored out.

See git log -p v2.6.30..v3.4 --follow -- drivers/net/ethernet/realtek/r8169.c
for the whole gore.

> My hope was to first receive feedback and identify some probably related
> known bug, in order to avoid searching for a solution by trial and error or
> by updating the whole environment.

You should really try 3.4 and revert 036dafa28da1e2565a8529de2ae663c37b7a0060.
It's the best I can suggest.

-- 
Ueimor
