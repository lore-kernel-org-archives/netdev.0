From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: zd1211 ported to Devicescape stack
Date: Sat, 2 Dec 2006 18:57:37 +0100
Message-ID: <20061202175737.GA5577@p15091797.pureserver.info>
References: <200612020316.50965.flamingice@sourmilk.net> <4571A295.4030700@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Wu <flamingice@sourmilk.net>, netdev@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Luis Rodriguez <mcgrof@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:21204 "EHLO
	p15091797.pureserver.info") by vger.kernel.org with ESMTP
	id S1424292AbWLBR5i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Dec 2006 12:57:38 -0500
To: Daniel Drake <dsd@gentoo.org>
Content-Disposition: inline
In-Reply-To: <4571A295.4030700@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06-12-02 10:58 Daniel Drake wrote:

> Michael Wu wrote:
> >Hi,
> >	I have finished a port of the zd1211 driver to the Devicescape 
> >	802.11 stack. 
> 
> Yeah!! thanks so much for doing this.
> 
> Are you willing to maintain this in terms of porting upcoming patches to 
> it? I think I also speak for Ulrich when I say that at the moment we are 
> more concerned about getting our work into mainline and don't have time 
> to maintain a ported driver, but we will be happy to switch immediately 
> as soon as devicescape is declared ready for mainline inclusion.

I intend to track the d80211 stack, care for the forward porting
and see also a number of things, which should be done for d80211.

- 802.11a support
- better d80211 integration (d80211_tx_status, led stuff)
- cleanups

Daniel your hardware crypto patches should certainly be included
here.

This will make the d80211 driver the development branch and the
mainline driver the maintenance branch. As already stated I intend
care for forwardportsi of the mainline fixes, but IMHO we should
not care to much for backports and backport compatibility. 

-- 
Uli Kunitz
