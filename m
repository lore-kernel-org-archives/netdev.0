From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Tue, 1 May 2007 22:07:23 +0200
Message-ID: <20070501200723.GA19212@electric-eye.fr.zoreil.com>
References: <200704162241.31729.peter.missel@onlinehome.de> <200704172236.43280.peter.missel@onlinehome.de> <20070417223027.GA9517@electric-eye.fr.zoreil.com> <200705012119.48598.peter.missel@onlinehome.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Peter Missel <peter.missel@onlinehome.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:49540 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753831AbXEAUKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 16:10:05 -0400
Content-Disposition: inline
In-Reply-To: <200705012119.48598.peter.missel@onlinehome.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Missel <peter.missel@onlinehome.de> :
[...]
> Sorry, returning to this issue took me longer than anticipated before I could 
> return to the issue.

No problem, it is in my bugs store.

[...]
> Unfortunately the driver that comes with 2.6.18 doesn't appear to support 
> mii-tool. I get this message:
> 
> >Mars:~ # mii-tool -w eth2
> >SIOCGMIIPHY on 'eth2' failed: Operation not supported

Are you sure that your system is kept up-to-date ?

If I read correctly, Suse's 10.2's kernel 2.6.18.8-0.1 includes a
2.6.19-rc5 version of the r8169 driver. It should support the relevant
ioctl (please add '-v -v' to the mii-tool command btw).

However...

> Next I'll be looking at the provided backport. Also, I'll be confronted with 
> SuSE 10.2 and the RTL8111B at work next week.

... for the 8168/8111B, it is strongly suggested to use 2.6.21 +
http://www.fr.zoreil.com/people/francois/misc/20070430-2.6.21-r8169-test.patch

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
