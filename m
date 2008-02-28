From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [2.6.25 patch] FIXED_PHY must depend on PHYLIB=y
Date: Thu, 28 Feb 2008 11:30:34 +0100
Message-ID: <20080228103034.GA8174@aepfle.de>
References: <200802271158.00453.olaf@aepfle.de> <20080227150754.GA29269@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Anton Vorontsov <avorontsov@ru.mvista.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	Jeff Garzik <jeff@garzik.org>,
	Kumar Gala <galak@kernel.crashing.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <adrian.bunk@movial.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:54591 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbYB1KbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 05:31:24 -0500
Content-Disposition: inline
In-Reply-To: <20080227150754.GA29269@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 27, Adrian Bunk wrote:

> This patch fixes the following build error introduced by commit 
> a79d8e93d300adb84cccc38ac396cfb118c238ad and reported by Olaf Hering:
> 
> <--  snip  -->
> 
> ...
>   LD      .tmp_vmlinux1
> arch/powerpc/sysdev/built-in.o: In function `of_add_fixed_phys':
> fsl_soc.c:(.init.text+0xd34): undefined reference to `fixed_phy_add'
> make: *** [.tmp_vmlinux1] Error 1

Yes, this patch helps.
Thanks.

