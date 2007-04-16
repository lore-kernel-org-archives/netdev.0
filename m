From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 2.2LK: Low link speed after suspend
Date: Mon, 16 Apr 2007 23:09:40 +0200
Message-ID: <20070416210940.GA13710@electric-eye.fr.zoreil.com>
References: <200704162241.31729.peter.missel@onlinehome.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Peter Missel <peter.missel@onlinehome.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:57853 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030975AbXDPVNN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Apr 2007 17:13:13 -0400
Content-Disposition: inline
In-Reply-To: <200704162241.31729.peter.missel@onlinehome.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Missel <peter.missel@onlinehome.de> :
[...]
> Entering standby, the link speed goes down to 100 Mb as expected; the link 
> stays up during standby/suspend (for WOL purposes apparently).

Yes.

> Now after resume, the link is working OK but doesn't come back up to normal 
> gigabit operation. ifdown, unloading and reloading the r8169 module, and then 
> ifup again fixes it.
> 
> If there's something more I can do to help debug this, please let me know. 
> Please be sure to copy me, since my list traffic here is still somewhat 
> unreliable. Thanks.

Can you try 2.6.21-rc7 + (either):
- http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.21-rc7/r8169-20070416
- http://www.fr.zoreil.com/people/francois/misc/20070416-2.6.21-rc7-r8169-test.patch

If it does not work better, please fill an entry for it at bugzilla.kernel.org,
Cc: it to me and attach the output of a registers dump taken from mii-tool before
suspend and after a failed resume.

-- 
Ueimor

Anybody got a battery for my Ultra 10 ?
