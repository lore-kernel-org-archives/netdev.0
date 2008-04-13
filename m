From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] [NET] [ISDN]: Do not validate ISDN net device address
	prior to interface-up
Date: Sun, 13 Apr 2008 10:27:38 +0200
Message-ID: <20080413082738.GA2788@ami.dom.local>
References: <1207839617.4311.6.camel@compaq.thuisdomein> <4801A85F.8090906@trash.net> <4801BF1C.30207@gmail.com> <4801BEB4.6090909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, Jeff Garzik <jgarzik@redhat.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:19525 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbYDMIXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 04:23:12 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1077765fgb.17
        for <netdev@vger.kernel.org>; Sun, 13 Apr 2008 01:23:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4801BEB4.6090909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 13, 2008 at 10:05:08AM +0200, Patrick McHardy wrote:
...
> In my opinion a proper error code like EADDRNOTAVAIL is enough, we
> have thousands of checks that might make things fail, should we
> add a printk to every one of those?

IMHO yes - but only when "the functionality" is changed causing
regressions like this. BTW, I've assisted some similar case in
bugzilla, and I guess users will still ask for an explanation after
this error code change.

Jarek P.
