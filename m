From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 23:54:26 +0100
Message-ID: <200901302354.27497.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901300110.56533.rjw@sisk.pl> <alpine.DEB.2.00.0901301730230.6574@parag-desktop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:50621 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756673AbZA3WzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 17:55:08 -0500
In-Reply-To: <alpine.DEB.2.00.0901301730230.6574@parag-desktop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 30 January 2009, Parag Warudkar wrote:
> 
> On Fri, 30 Jan 2009, Rafael J. Wysocki wrote:
> 
> > 
> > I still am interested if it makes any difference for Parag.
> 
> No difference - tg3 is still dead after resume.

Thanks for testing.

Well, I'm not sure if tg3 is at fault, really.

What happens if you unload tg3 before suspend and load it back after the
resume?

Rafael
