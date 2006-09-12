From: Corentin CHARY <corentincj@iksaif.net>
Subject: Re: r8168, 2.6.17 et r8169.c
Date: Tue, 12 Sep 2006 13:29:25 +0200
Message-ID: <200609121329.26159.corentincj@iksaif.net>
References: <200609091201.03603.corentincj@iksaif.net> <200609111309.08447.corentincj@iksaif.net> <20060911201348.GA8188@electric-eye.fr.zoreil.com>
Reply-To: corentincj@iksaif.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from iksaif.dns26.com ([84.246.226.15]:41098 "EHLO iksaif.net")
	by vger.kernel.org with ESMTP id S1030186AbWILL3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2006 07:29:11 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060911201348.GA8188@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Can you try against 2.6.18-rc6:
> http://www.fr.zoreil.com/people/francois/misc/20060911-2.6.18-rc6-r8169-tes
>t.patch
>
> If the driver does not work, which in itself would be fairly disappointing,
> revert (patch -R) 0009 found in the 2.6.18-rc5 directory and try again.
>
> If the driver still does not work, revert 0007 found in the 2.6.18-rc5
> directory and try again.
>
> If the driver still does not work, send the .c file, send your working
> 2.6.17-rc6 driver and send the _complete_ dmesg from boot for both
> kernels because something is badly screwed.

As I Tell you in the first mail, I tested only on 2.6.17 kernels, so I had to 
modify 2 lines to compile with 2.6.18 patchs.
Today, I tested on a 2.6.18-r6 Kernel, and it work perfectly (without 
mii-tool !).
On 2.6.17, even with patch -R, nothing to do ..

If you wan't dmesg of 2.6.17, I can send you, but the driver is for 2.6.18, so 
I don't think it's usefull to get It work on 2.6.17.

Thanks for your help ;)
-- 
CHARY 'Iksaif' Corentin
iksaif@gmail.com - corentincj@yahoo.fr
http://xf.iksaif.net
