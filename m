From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [OOPS] bcm43xx oops on 2.6.20-rc1 on x86_64
Date: Sat, 30 Dec 2006 22:32:45 +0100
Message-ID: <20061230213245.GD20714@stusta.de>
References: <Pine.LNX.4.64.0612171510030.17532@squeaker.ratbox.org> <20061230192104.GB20714@stusta.de> <4596D8DE.2030408@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aaron Sethman <androsyn@ratbox.org>, linux-kernel@vger.kernel.org,
	linville@tuxdriver.com, netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:1219 "HELO
	mailout.stusta.mhn.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1030343AbWL3Vcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Dec 2006 16:32:45 -0500
To: Larry Finger <larry.finger@lwfinger.net>
Content-Disposition: inline
In-Reply-To: <4596D8DE.2030408@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 30, 2006 at 03:23:42PM -0600, Larry Finger wrote:
> Adrian Bunk wrote:
> > On Sun, Dec 17, 2006 at 03:15:28PM -0500, Aaron Sethman wrote:
> >> Just was loading the bcm43xx module and got the following oops. Note that 
> >> this card is one of the newer PCI-E cards.  If any other info is needed 
> >> let me know.
> > 
> > Is this issue still present in 2.6.10-rc2-git1?
> > 
> > If yes, was 2.6.19 working fine?
>...
> 
> Any oops involving wireless extensions is due to 2.6.20-rc1 and -rc2 not having the fix for softmac
> that is necessitated by the 2.6.20 changes in the work structure.

"Any oops" are very strong words.

It wouldn't be the first time that we have several similar bug reports, 
and it turns out that one is for a completely different issue...

> The needed patch has now been
> pushed by Jeff to Andrew and Linus, and should be in -rc3. In the meantime, it is attached.

That's why I asked for testing with 2.6.20-rc2-git1 that includes the 
two ieee80211softmac patches.

> Larry

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

