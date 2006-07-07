From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH, RFT] bcm43xx: init routine rewrite (bugfix)
Date: Fri, 7 Jul 2006 15:14:31 +0200
Message-ID: <200607071514.31847.mb@bu3sch.de>
References: <200607012214.24335.mb@bu3sch.de> <20060706193455.GB6259@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:5510
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1751201AbWGGNNg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 09:13:36 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060706193455.GB6259@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 06 July 2006 21:35, you wrote:
> On Sat, Jul 01, 2006 at 10:14:23PM +0200, Michael Buesch wrote:
> > Hi,
> > 
> > This patch is a rewrite of the bcm43xx init routine.
> > It is supposed to fix several issues:
> > * up-down-up.. sequence stale-data issue
> >   (This may fix dhclient issues)
> > * Fix init vs IRQ race.
> > * Fix init for cards with multiple cores (APHY)
> >   (untested)
> > * Fix controller restart breakage.
> > * Make used wireless core (phymode) selectable at runtime.
> > * Well, few others. Don't remember :)
> 
> Since your subject includes "RFT", I'm NOT going to apply this.
> Please correct me if your desire is otherwise.

Yes, that's right. Please don't apply this, yet.
I will resend it soon in a submittable mail.

As a general rule, don't apply any patches from me to any
trees that have RFT in Subject.

-- 
Greetings Michael.
