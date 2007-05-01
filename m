From: Peter Missel <peter.missel@onlinehome.de>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Tue, 1 May 2007 21:19:48 +0200
Message-ID: <200705012119.48598.peter.missel@onlinehome.de>
References: <200704162241.31729.peter.missel@onlinehome.de> <200704172236.43280.peter.missel@onlinehome.de> <20070417223027.GA9517@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:63314 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161811AbXEATT6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2007 15:19:58 -0400
In-Reply-To: <20070417223027.GA9517@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois!

Sorry, returning to this issue took me longer than anticipated before I could 
return to the issue.

> Hardly: the r8169 driver has been modified by ~40 patches from 2.6.18 to
> now.
>
> There is an ugly hack^W^W quick backport for 2.6.18 at:
> http://www.fr.zoreil.com/people/francois/backport/r8169/20070418-00
>
> It compiles but I do not know if it works and I strongly suggest to use
> a more recent kernel package anyway.

Unfortunately the driver that comes with 2.6.18 doesn't appear to support 
mii-tool. I get this message:

>Mars:~ # mii-tool -w eth2
>SIOCGMIIPHY on 'eth2' failed: Operation not supported

Next I'll be looking at the provided backport. Also, I'll be confronted with 
SuSE 10.2 and the RTL8111B at work next week.

I'll keep you updated.

Peter
