From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH 0/5] late Gigaset fixes for 2.6.35
Date: Mon, 21 Jun 2010 21:02:41 -0700
Message-ID: <20100622040241.GB4151@kroah.com>
References: <20100622-patch-gigaset-00.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <keil@b1-systems.de>, stable@kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:38536 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949Ab0FVEEx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 00:04:53 -0400
Content-Disposition: inline
In-Reply-To: <20100622-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 22, 2010 at 02:28:41AM +0200, Tilman Schmidt wrote:
> Karsten, David,
> 
> following are five patches to the Gigaset driver fixing reported
> problems with two CAPI applications (Asterisk and capifax). They
> fix serious bugs, though not technically regressions, and I would
> therefore appreciate if they could still make it into release
> 2.6.35. Otherwise please queue them for the first stable cycle.
> 
> These should also go into 2.6.34-stable. They apply cleanly to
> 2.6.34 except for some offsets in file drivers/isdn/gigaset/capi.c.

To get a patch in the -stable tree, please just add a simple:
	Cc: stable <stable@kernel.org>
to the body of the patch in the signed-off-by area.  That way, when the
patches go to Linus, I get automatically notified of them and you don't
have to do anything.  If you don't, then I have to go and dig and watch
the tree to see if they are really applied or not, which, when
confronted with 200+ patches that need to be manually watched for this
way, does not scale...

thanks,

greg k-h
