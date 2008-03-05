From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [2.6.25 patch] FIXED_PHY must depend on PHYLIB=y
Date: Wed, 05 Mar 2008 07:18:35 -0500
Message-ID: <47CE8F9B.8020003@garzik.org>
References: <200802271158.00453.olaf@aepfle.de> <20080227150754.GA29269@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Olaf Hering <olaf@aepfle.de>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	Kumar Gala <galak@kernel.crashing.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <adrian.bunk@movial.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51069 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765844AbYCEMSp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 07:18:45 -0500
In-Reply-To: <20080227150754.GA29269@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
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
> 
> <--   snip  -->
> 
> Signed-off-by: Adrian Bunk <adrian.bunk@movial.fi>

applied (but sad)


