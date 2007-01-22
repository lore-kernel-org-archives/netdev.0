From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: Fix problem with >1 GB RAM
Date: Mon, 22 Jan 2007 21:35:59 +0100
Message-ID: <200701222135.59314.mb@bu3sch.de>
References: <45b240d6.SHryQ/4Jr/1MvQso%Larry.Finger@lwfinger.net> <200701221920.28938.mb@bu3sch.de> <45B51C31.10000@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:57567
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932471AbXAVUhZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 15:37:25 -0500
To: Larry Finger <larry.finger@lwfinger.net>
In-Reply-To: <45B51C31.10000@lwfinger.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 22 January 2007 21:18, Larry Finger wrote:
> When I looked at the b44 driver to see how that code handled the problem, it used the pci-form of
> the calls rather than the dma-version. Thus I switched early in the debug process - even before I
> had the necessary hardware. Once I got it working and understood the problem, I never tried
> restoring the dma-forms.

Ok, I see. I'm OK with that.

> > That isn't a BUG. Just remove this call, please.
> 
> It was accidentally left in from my debugging. I have already submitted a revised version to
> Linville that removes this, and one other BUG statement that you didn't note.

Yeah, saw it too late. That patch is ACKed then by me.

-- 
Greetings Michael.
