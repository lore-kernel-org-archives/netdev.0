From: Jason Lunz <lunz@falooley.org>
Subject: Re: [PATCH] Mark frame diverter for future removal.
Date: Sun, 17 Sep 2006 21:28:42 +0000 (UTC)
Message-ID: <eekem9$est$1@sea.gmane.org>
References: <20060914120456.4291a16d@localhost.localdomain>
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:30633 "EHLO ciao.gmane.org")
	by vger.kernel.org with ESMTP id S965111AbWIQV24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2006 17:28:56 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1GP4C2-0007LA-6r
	for netdev@vger.kernel.org; Sun, 17 Sep 2006 23:28:50 +0200
Received: from adsl-065-013-029-145.sip.asm.bellsouth.net ([65.13.29.145])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2006 23:28:50 +0200
Received: from lunz by adsl-065-013-029-145.sip.asm.bellsouth.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 17 Sep 2006 23:28:50 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

shemminger@osdl.org said:
> The code for frame diverter is unmaintained and has bitrotted.
> The number of users is very small and the code has lots of problems.
> If anyone is using it, they maybe exposing themselves to bad packet attacks.

I seem to recall looking at frame diverter and thinking that everything
it does can be done with ebtables. All the more reason to remove it.

Jason

