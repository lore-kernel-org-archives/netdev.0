From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8168, 2.6.17 et r8169.c
Date: Mon, 11 Sep 2006 22:13:48 +0200
Message-ID: <20060911201348.GA8188@electric-eye.fr.zoreil.com>
References: <200609091201.03603.corentincj@iksaif.net> <200609091451.14579.corentincj@iksaif.net> <20060910214254.GA22831@electric-eye.fr.zoreil.com> <200609111309.08447.corentincj@iksaif.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:38373 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S965029AbWIKUQn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 16:16:43 -0400
To: Corentin CHARY <corentincj@iksaif.net>
Content-Disposition: inline
In-Reply-To: <200609111309.08447.corentincj@iksaif.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Corentin CHARY <corentincj@iksaif.net> :
> With the 2.6.17 Patchs :
> 
[...]
> xfport /usr/src/linux # mii-tool eth0
> SIOCGMIIPHY on 'eth0' failed: Operation not supported

Expected result.

[...]
> With NET_IP_ALIGN + 6 : It does *exactly* the same thing, *but* it works 
> perfectly !!!

Expected result.

[...]
> So I now use that, but I test 2.6.18 patchs.
> 
> With the  2.6.18 kernel patchs :
> same thing as before but mii-tool works (i think i forget patchs 10 and 11 
> last time, sry).
> BUT: i can't ping .. maybe it's just because I don't use mii-tool in the right 
> way :(

Something went wrong.

Can you try against 2.6.18-rc6:
http://www.fr.zoreil.com/people/francois/misc/20060911-2.6.18-rc6-r8169-test.patch

If the driver does not work, which in itself would be fairly disappointing, 
revert (patch -R) 0009 found in the 2.6.18-rc5 directory and try again.

If the driver still does not work, revert 0007 found in the 2.6.18-rc5
directory and try again.

If the driver still does not work, send the .c file, send your working
2.6.17-rc6 driver and send the _complete_ dmesg from boot for both
kernels because something is badly screwed.

-- 
Ueimor
