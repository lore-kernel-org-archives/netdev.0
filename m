From: Stefan Schmidt <stefan@datenfreihafen.org>
Subject: Re: ieee802154: Source addr fix for dgram and some small at86rf230
 driver enhancements
Date: Wed, 27 Mar 2013 18:52:05 +0000
Message-ID: <20130327185204.GH22584@novatech.datenfreihafen.org>
References: <1364337691-20163-1-git-send-email-stefan@datenfreihafen.org>
 <20130327.005318.1058473513349640907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefan@datenfreihafen.org, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net, alan@signal11.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sirius.lasnet.de ([78.47.116.19]:60530 "EHLO sirius.lasnet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753108Ab3C0SwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 14:52:14 -0400
Content-Disposition: inline
In-Reply-To: <20130327.005318.1058473513349640907.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On Wed, 2013-03-27 at 00:53, David Miller wrote:
> From: Stefan Schmidt <stefan@datenfreihafen.org>
> Date: Tue, 26 Mar 2013 22:41:28 +0000
> 
> > Hello.
> > 
> > Second version. Changes since version 1:
> > - Obey 80 chars rules
> > - Switch logging mode to vdbg to avoid noise
> > - Remove uneeded might_sleep()
> > 
> > Thanks Alan, Werner and Alex for the feedback.
> > 
> > I feel these are ready so I added DaveM and netdev to pick them up if they think
> > the same.
> 
> All applied.

Thanks. That was quick. :)

I wonder what happened to the from of two of my commits. Looking at
your repo they only show up my email address:

https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=1486774d69f6e58da16cdae8f17c77ec6569f711
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=028889b0b32064a3a23d6d8d4ef589a42a6d43c7

The one from Stephen is fine
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=6364e6ee788ae60f1c2de5c59e39adb157327e6c

The later as an explicit from as he was the author and I just the
sender. For the two problematic ones git am should have picked up the
normal mail from header, no?

I did the patches from my local branch with git format-patch and git
send-email as I have done quite often already. Looking at the mails I
got as CC the from line looks fine too. Also I just saved the mails
here from my mutt and did a git am on it and the name was picked up
correctly.

Is there still some error on my side? I would really like to get it
fixed if there is one. :) Or was it juts a glitch on your side?

regards
Stefan Schmidt
