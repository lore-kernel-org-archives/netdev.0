From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Wed, 6 Aug 2008 21:50:24 +0200
Message-ID: <20080806195023.GA15747@electric-eye.fr.zoreil.com>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com> <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com> <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com> <20080805214250.GA23226@electric-eye.fr.zoreil.com> <loom.20080806T144054-201@post.gmane.org> <20080806181235.GA17174@electric-eye.fr.zoreil.com> <25625.84.245.32.19.1218051465.squirrel@secure.greenhost.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Indan Zupancic <indan@nul.nu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:34011 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751796AbYHFTyn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 15:54:43 -0400
Content-Disposition: inline
In-Reply-To: <25625.84.245.32.19.1218051465.squirrel@secure.greenhost.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Indan Zupancic <indan@nul.nu> :
[...]
> "git log drivers/net/r8169.c" shows only two commits since May 11:

$ git rev-list v2.6.26..v2.6.27-rc1 -- drivers/net/r8169.c 
77332894c21165404496c56763d7df6c15c4bb09
f887cce8de019bb32917789379af89ae4c0294ee
865c652d6be9929927cabdc54b137b7541eb6612
1087f4f4af302e6e2fa40dd741f306444d90bece

> r8169: avoid thrashing PCI conf space above RTL_GIGA_MAC_VER_06
> 
> r8169: multicast register update
> 
> Then at May 11 comes:
> 
> r8169: remove non-napi code
> 
> But I think that was in 2.6.26 already.

No. :o)

[...]
> Yes, but it takes quite a lot of time and I'm busy at the moment,
> so I'll wait till rc2 to see if it's fixed then. If it isn't I'll
> start digging.

Ok.

-- 
Ueimor
